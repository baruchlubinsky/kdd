defmodule KddWeb.Apps.BudgetController do
  use KddWeb, :controller
  import Ecto.Query

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

    Kdd.Repo.one(from(Kdd.Apps.Budget, where: [account_id: ^user.notion_account.id])) || %Kdd.Apps.Budget{account_id: user.notion_account.id}
    |> Kdd.Apps.Budget.changeset(params["budget"])
    |> Kdd.Repo.insert_or_update!()

    put_flash(conn, :info, "Saved.")
    |> redirect(to: ~p{/apps/budget})
  end
end
