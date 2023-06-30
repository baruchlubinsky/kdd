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
    <.input type="text" label="Title" name="name" value="" />
    <.input type="select" label="Category" name="category" options={@categories || []} value="" disabled={!@categories}/>
    <.input type="number" label="Amount" name="amount" value="" />
    <.button>Save</.button>
    </.simple_form>
    """
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_info({:load_categories, account}, socket) do

    app = Kdd.Repo.one!(from(Kdd.Apps.Budget, where: [account_id: ^account.id]))

    category_options =
      Kdd.Notion.Database.query(app.budget_db, nil, account.access_token)
      |> Kdd.Notion.Transform.table_to_options("Category")

    {:noreply, assign(socket, categories: category_options)}

  end

end
