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
    form =  Kdd.Apps.Budget.changeset(record, %{})
    render(conn, :settings, form: form)
  end

  def configure(conn, params) do
    user = conn.assigns[:user]

    record = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id])) || %Kdd.Apps.Budget{account_id: user.notion_account.id}

    record
    |> Kdd.Apps.Budget.changeset(params["budget"])
    |> Kdd.Repo.insert_or_update!()

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
      |> Kdd.Notion.Transform.table_to_options("Category")

      render(conn, :expense, categories: category_options)
    end
  end

  def record_expense(conn, %{"name" => name, "amount" => amount, "category" => category}) do
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

  def plot(conn, _params) do
    put_layout(conn, false)
    |> put_root_layout(false)
    |> render(:plot)
  end

  def month_to_date(conn, _params) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id]))

    if is_nil(app) do
      raise "App is not configured."
    else
      data = monthly_data(app.expense_db, app.budget_db, user.notion_account.access_token)
      json(conn, data)
    end
  end

  def monthly_data(expenses, categories, token) do
    cat_filter =
      %{"filter" =>
        %{
          "property" => "Amount",
          "number" => %{
            "less_than" => 0
          }
        }
      }

    exp_filter =
      %{"filter" =>
        %{
          "timestamp" => "created_time",
          "created_time" => %{
            "past_month" => %{}
          }
        }
      }

    expense_data =
      Kdd.Notion.Database.query(expenses, exp_filter, token)
      |> Kdd.Notion.Transform.pivot_table("Amount", "Category")
      |> Enum.filter(fn {k, _v} -> is_binary(k) end)
      |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)

    category_resp = Kdd.Notion.Database.query(categories, cat_filter, token)

    category_data = Kdd.Notion.Transform.pivot_table(category_resp, "Amount", "Category")

    category_ids = Kdd.Notion.Transform.table_to_options(category_resp, "Category")

    Enum.map(category_ids, fn {cat, id} ->
      {_, total} =
        Enum.find(expense_data, {nil, 0}, fn
          {^id, _sum} -> true
          _ -> false
        end)
      {_, [budget]} =
        Enum.find(category_data, fn
          {^cat, _amount} -> true
          _ -> false
        end)
      [
        %{"category" => cat, "type" => "budget", "value" => -budget},
        %{"category" => cat, "type" => "spend", "value" => total}
      ]
    end)
    |> List.flatten()


  end

end
