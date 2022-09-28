defmodule KddWeb.BudgetController do
  use KddWeb, :controller
  import KddWeb.NotionController, only: [authenticate: 2]

  plug :authenticate, apps: [:budget_app]

  def index(conn, _params) do
    user = conn.assigns[:notion_user]
    app = user.budget_app

    if is_nil(app) do
      redirect(conn, to: Routes.budget_path(conn, :settings))
    else
      summary = month_to_date(app.expenses, app.categories, user.access_token)
      chart = Plotly.Charts.stacked_bar(summary, "Budget", "Spend")

      render(conn, "index.html", plot_data: chart)
    end
  end

  def settings(conn, _parmas) do
    template_url = "https://www.notion.so/Finance-Template-150c0d4d2b484c3facb558fb2b8c5e58"
    user = conn.assigns[:notion_user]
    app = Kdd.BudgetApp.changeset(user.budget_app)

    render(conn, "settings.html", template_url: template_url, budget_app: app)
  end

  def configure(conn, %{"budget_app" => args}) do
    user = conn.assigns[:notion_user]
    app = user.budget_app

    if is_nil(app) do
      Kdd.BudgetApp.changeset(%Kdd.BudgetApp{user_id: user.id}, args)
      |> Kdd.Repo.insert()
    else
      Kdd.BudgetApp.changeset(app, args)
      |> Kdd.Repo.update()
    end
    |> case do
      {:ok, _app} -> redirect(conn, to: Routes.budget_path(conn, :expense))
      {:error, error} ->
        IO.inspect(error)
        redirect(conn, to: Routes.budget_path(conn, :settings))
      end
  end

  def expense(conn, _params) do
    user = conn.assigns[:notion_user]
    app = user.budget_app
    if is_nil(app) do
      put_flash(conn, :info, "No database has been configured.")
      |> redirect(to: Routes.budget_path(conn, :settings))
    else

      categories =
        Notion.API.fetch_table(app.categories, user.access_token)
        |> Notion.Data.table_to_options("Category")
      render(conn, "expense.html", categories: categories)
    end
  end

  def create(conn, %{"name" => name, "amount" => amount, "category" => category}) do
    user = conn.assigns[:notion_user]
    app = user.budget_app
    if is_nil(app) do
      put_flash(conn, :info, "No database has been configured.")
      |> redirect(to: Routes.budget_path(conn, :settings))
    else
      Notion.Templates.new_page("Name", name)
      |> Notion.Templates.add_property(Notion.Templates.number_prop("Amount", amount))
      |> Notion.Templates.add_property(Notion.Templates.relation_prop("Category", app.categories, category))
      |> Notion.Templates.add_property(Notion.Templates.datestamp("Date"))
      |> Notion.API.create_page(app.expenses, user.access_token)

      redirect(conn, to: Routes.budget_path(conn, :expense))
    end

  end

  def month_to_date(expenses, categories, token) do
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
      Notion.API.fetch_table(expenses, exp_filter, token)
      |> Notion.Data.pivot_table("Amount", "Category")
      |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)

    category_resp = Notion.API.fetch_table(categories, cat_filter, token)

    category_data = Notion.Data.pivot_table(category_resp, "Amount", "Category")

    category_ids = Notion.Data.table_to_options(category_resp, "Category")

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
      {cat, -budget, total}
    end)


  end


end
