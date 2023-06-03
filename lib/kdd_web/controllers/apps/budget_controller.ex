defmodule KddWeb.Apps.BudgetController do
  use KddWeb, :controller
  import Ecto.Query

  alias Kdd.Notion.Templates

  plug :load_user!, except: [:index]

  def index(conn, _params) do
    render(conn, :index)
  end

  def settings(conn, _params) do
    user = conn.assigns[:user]
    record = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id])) || %Kdd.Apps.Budget{}
    changeset = Kdd.Apps.Budget.changeset(record, %{})
    render(conn, :settings, changeset: changeset)
  end

  def configure(conn, params) do
    user = conn.assigns[:user]

    record = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id])) || %Kdd.Apps.Budget{account_id: user.notion_account.id}

    record
    |> Kdd.Apps.Budget.changeset(params["budget"])
    |> Kdd.Repo.insert_or_update!()
    |> IO.inspect()

    put_flash(conn, :info, "Saved.")
    |> redirect(to: ~p{/apps/budget})
  end

  def expense(conn, _params) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id]))

    if is_nil(app) do
      put_flash(conn, :warn, "App is not configured.")
      |> redirect(to: ~p"/apps/budget/settings")
    else
      category_options =
      Kdd.Notion.Database.query(app.budget_db, nil, user.notion_account.access_token)
      |> Kdd.Notion.Process.table_to_options("Category")

      render(conn, :expense, categories: category_options)
    end
  end

  def record_expense(conn, %{"expense" => %{"name" => name, "amount" => amount, "category" => category}}) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id]))

    if is_nil(app) do
      put_flash(conn, :warn, "App is not configured.")
      |> redirect(to: ~p"/apps/budget/settings")
    else
      Templates.new_page("Name", name)
      |> Templates.add_property(Templates.number_prop("Amount", amount))
      |> Templates.add_property(Templates.relation_prop("Category", app.budget_db, category))
      |> Templates.add_property(Templates.datestamp("Date"))
      |> Kdd.Notion.Page.create_record(app.expense_db, user.notion_account.access_token)

      redirect(conn, to: ~p"/apps/budget/expense")
    end
  end
end
