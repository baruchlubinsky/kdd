defmodule KddWeb.LiveExpense do
  use KddWeb, :live_view
  import Ecto.Query

  def mount(_params, session, socket) do
    account = Kdd.Repo.get_by!(Kdd.Notion.Account, user_id: session["user_id"])
    socket = assign(socket, notion_id: account.id)

    if is_nil(socket.assigns[:categories]) do
      send(self(), {:load_categories, account})
      {:ok, assign(socket, categories: false, expense: new_form())}
    else
      {:ok, assign(socket, expense: new_form())}
    end
  end

  def new_form() do
    to_form(%{"amount" => "", "name" => "", "category" => nil})
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@expense} phx-submit="save">
      <:loading>
        <div class="while-submitting">
          <.loading_spinner>
            Saving
          </.loading_spinner>
        </div>
      </:loading>
      <.input type="text" label="Title" field={@expense[:name]} />
      <.input
        type="select"
        label="Category"
        field={@expense[:category]}
        options={@categories || []}
        disabled={!@categories}
      />
      <.input type="number" label="Amount" field={@expense[:amount]} />
      <.button>Save</.button>
    </.simple_form>
    """
  end

  def handle_event("save", %{"name" => name, "amount" => amount, "category" => category}, socket) do
    alias KddNotionEx.Templates

    account = Kdd.Repo.get!(Kdd.Notion.Account, socket.assigns.notion_id)
    app = Kdd.Repo.get_by(Kdd.Apps.Budget, account_id: account.id)

    socket =
    if is_nil(app) do
      put_flash(socket, :warn, "App is not configured.")
      |> push_navigate(to: ~p"/apps/budget/settings")
    else
      Templates.new_page("Name", name)
      |> Templates.add_property(Templates.number_prop("Amount", amount))
      |> Templates.add_property(Templates.relation_prop("Category", app.budget_db, category))
      |> Templates.add_property(Templates.datestamp("Date"))
      |> KddNotionEx.Page.create_record(app.expense_db, account.access_token)

      put_flash(socket, :info, "Saved.")
    end

    {:reply, %{}, assign(socket, :expense, new_form())}
  end

  def handle_info({:load_categories, account}, socket) do
    app = Kdd.Repo.one!(from(Kdd.Apps.Budget, where: [account_id: ^account.id]))

    category_options =
      KddNotionEx.Database.query(app.budget_db, nil, account.access_token)
      |> KddNotionEx.Transform.table_to_options("Category")

    {:noreply, assign(socket, categories: category_options)}
  end
end
