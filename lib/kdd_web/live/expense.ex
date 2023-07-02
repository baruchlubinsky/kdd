defmodule KddWeb.LiveExpense do
  use KddWeb, :live_view
  import Ecto.Query

  def mount(_params, session, socket) do
    account = Kdd.Repo.get_by!(Kdd.Notion.Account, user_id: session["user_id"])
    socket = assign(socket, notion_id: account.id)

    send(self(), {:load_categories, account})

    {:ok, assign(socket, categories: false)}
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={%{}} as={:expense} phx-submit="save">
      <:loading>
        <div class="while-submitting">
          <.loading_spinner>
          Saving
          </.loading_spinner>
        </div>
      </:loading>
      <.input type="text" label="Title" name="name" value="" />
      <.input type="select" label="Category" name="category" options={@categories || []} value="" disabled={!@categories}/>
      <.input type="number" label="Amount" name="amount" value="" />
      <.button >Save</.button>
    </.simple_form>
    """
  end

  def handle_event("save",  %{"name" => name, "amount" => amount, "category" => category}, socket) do
    alias Kdd.Notion.Templates

    account = Kdd.Repo.get!(Kdd.Notion.Account, socket.assigns.notion_id)
    app = Kdd.Repo.get_by(Kdd.Apps.Budget, account_id: account.id)

    if is_nil(app) do
      put_flash(socket, :warn, "App is not configured.")
      |> push_navigate(to: ~p"/apps/budget/settings")
    else
      Templates.new_page("Name", name)
      |> Templates.add_property(Templates.number_prop("Amount", amount))
      |> Templates.add_property(Templates.relation_prop("Category", app.budget_db, category))
      |> Templates.add_property(Templates.datestamp("Date"))
      |> Kdd.Notion.Page.create_record(app.expense_db, account.access_token)
    end

    {:noreply, put_flash(socket, :info, "Saved #{name}")}
  end

  def handle_info({:load_categories, account}, socket) do

    app = Kdd.Repo.one!(from(Kdd.Apps.Budget, where: [account_id: ^account.id]))

    category_options =
      Kdd.Notion.Database.query(app.budget_db, nil, account.access_token)
      |> Kdd.Notion.Transform.table_to_options("Category")

    {:noreply, assign(socket, categories: category_options)}

  end

end
