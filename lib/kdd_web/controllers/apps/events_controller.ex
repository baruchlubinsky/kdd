defmodule KddWeb.Apps.EventsController do
  use KddWeb, :controller
  import Ecto.Query

  # alias Kdd.Notion.Templates

  plug :load_user!, only: [:settings, :configure]


  def settings(conn, _params) do
    user = conn.assigns[:user]
    record = Kdd.Repo.one(from(Kdd.Apps.Events, where: [account_id: ^user.notion_account.id])) || %Kdd.Apps.Events{}
    form =  Kdd.Apps.Events.changeset(record, %{})
    render(conn, :settings, form: form)
  end

  def configure(conn, params) do
    user = conn.assigns[:user]

    record = Kdd.Repo.one(from(Kdd.Apps.Events, where: [account_id: ^user.notion_account.id])) || %Kdd.Apps.Events{account_id: user.notion_account.id}

    record
    |> Kdd.Apps.Events.changeset(params["events"])
    |> Kdd.Repo.insert_or_update!()

    put_flash(conn, :info, "Saved.")
    |> redirect(to: ~p"/apps/events/#{record.link}")
  end

  def index(conn, %{"link" => link}) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: link) |> Kdd.Repo.preload(:account)

    filter = %{
      filter: %{
        "property" => "Posted",
        "checkbox" => %{
          "equals" => true
        }
      }
    }

    data =
      Kdd.Notion.Database.query(app.events_db, filter, app.account.access_token)
      |> Enum.map(&Kdd.Notion.Transform.page_as_record/1)

    render(conn, :index, title: app.host_name, data: data, base_url: ~p"/apps/events/#{app.link}")
  end

  def register(conn, %{"link" => link, "event_id" => event_id}) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: link) |> Kdd.Repo.preload(:account)

    Kdd.Notion.Page.get(event_id, app.account.access_token) |> IO.inspect
    render(conn, :register, event_id: event_id)
  end

end
