defmodule KddWeb.Apps.BudgetController do
  use KddWeb, :controller
  import Ecto.Query

  alias KddNotionEx.Templates

  plug :load_user!, except: [:index]

  def index(conn, _params) do
    render(conn, :index)
  end

  def settings(conn, _params) do
    user = conn.assigns[:user]

    record =
      Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id])) ||
        %Kdd.Apps.Budget{}

    render(conn, :settings, form: Ecto.Changeset.change(record))
  end

  def configure(conn, params) do
    user = conn.assigns[:user]

    record =
      Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id])) ||
        %Kdd.Apps.Budget{account_id: user.notion_account.id}

    req = KddNotionEx.Client.new(user.notion_account.access_token)

    record
    |> Kdd.Apps.Budget.changeset(params["budget"], req)
    |> Kdd.Repo.insert_or_update()
    |> case do
      {:ok, _} ->
        put_flash(conn, :info, "Saved.")
        |> redirect(to: ~p{/apps/budget})
      {:error, other} ->
        render(conn, :settings, form: other)
    end
  end

  def expense(conn, _params) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id]))

    if is_nil(app) do
      put_flash(conn, :warn, "App is not configured.")
      |> redirect(to: ~p"/apps/budget/settings")
    else
      form = Ecto.Changeset.change(%Kdd.Apps.ExpenseDB{:"Category" => nil, :"Date" => NaiveDateTime.utc_now()})

      category_options =
        KddNotionEx.Client.new(user.notion_account.access_token)
        |> KddNotionEx.Database.query(app.budget_db, nil)
        |> KddNotionEx.Transform.table_to_options("Category")

      render(conn, :expense, form: form, categories: category_options)
    end
  end

  def record_expense(conn, %{"expense_db" => %{"Name" => name, "Amount" => amount, "Category" => category}}) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id]))
    req = KddNotionEx.Client.new(user.notion_account.access_token)

    if is_nil(app) do
      put_flash(conn, :warn, "App is not configured.")
      |> redirect(to: ~p"/apps/budget/settings")
    else
      properties =
      Templates.new_page("Name", name)
      |> Templates.add_property(Templates.number_prop("Amount", amount))
      |> Templates.add_property(Templates.relation_prop("Category", app.budget_db, category))
      |> Templates.add_property(Templates.datestamp("Date"))


      KddNotionEx.Page.create_record(req, properties, app.expense_db)

      redirect(conn, to: ~p"/apps/budget/expense")
    end
  end

  def plot(conn, _params) do
    put_layout(conn, false)
    |> put_root_layout(false)
    |> render(:plot)
  end

  def report(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    render(conn, :report, %{start_date: start_date, end_date: end_date})
  end

  def report(conn, _params) do
    render(conn, :report, %{start_date: start_of_month(), end_date: end_of_month()})
  end

  def month_to_date(conn, params) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id]))

    if is_nil(app) do
      raise "App is not configured."
    else
      start_date = params["start_date"] || start_of_month()
      end_date = params["end_date"] || end_of_month()

      data =
        monthly_data(
          app.expense_db,
          app.budget_db,
          start_date,
          end_date,
          user.notion_account.access_token
        )

      json(conn, data)
    end
  end

  def start_of_month() do
    Date.utc_today() |> Date.beginning_of_month() |> Date.to_iso8601()
  end

  def end_of_month() do
    Date.utc_today() |> Date.end_of_month() |> Date.to_iso8601()
  end

  def monthly_data(expenses, categories, start_date, end_date, token) do
    cat_filter =
      %{
        "filter" => %{
          "property" => "Amount",
          "number" => %{
            "less_than" => 0
          }
        }
      }

    exp_filter =
      %{
        "filter" => %{
          "and" => [
            %{
              "property" => "Date",
              "date" => %{
                "on_or_after" => start_date
              }
            },
            %{
              "property" => "Date",
              "date" => %{
                "on_or_before" => end_date
              }
            }
          ]
        }
      }

    expense_data =
      KddNotionEx.Client.new(token)
      |> KddNotionEx.Database.query(expenses, exp_filter)
      |> KddNotionEx.Transform.pivot_table("Amount", "Category")
      |> Enum.filter(fn {k, _v} -> is_binary(k) end)
      |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)

    category_resp =
      KddNotionEx.Client.new(token)
      |> KddNotionEx.Database.query(categories, cat_filter)

    category_data = KddNotionEx.Transform.pivot_table(category_resp, "Amount", "Category")

    category_ids = KddNotionEx.Transform.table_to_options(category_resp, "Category")

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
