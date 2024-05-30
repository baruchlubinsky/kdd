defmodule KddWeb.Apps.EventsController do
  use KddWeb, :controller
  import Ecto.Query

  alias KddNotionEx.Templates

  plug :load_user!, only: [:settings, :configure]

  def settings(conn, _params) do
    user = conn.assigns[:user]

    record =
      Kdd.Repo.one(from(Kdd.Apps.Events, where: [account_id: ^user.notion_account.id])) ||
        %Kdd.Apps.Events{}

    form = Kdd.Apps.Events.changeset(record, %{})
    render(conn, :settings, form: form)
  end

  def configure(conn, params) do
    user = conn.assigns[:user]

    record =
      Kdd.Repo.one(from(Kdd.Apps.Events, where: [account_id: ^user.notion_account.id])) ||
        %Kdd.Apps.Events{account_id: user.notion_account.id}

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
        and: [
        %{
          "property" => "Date",
          "date" =>%{
            "on_or_after" => Date.to_iso8601(Date.utc_today())
          }
        },
        %{
          "property" => "Posted",
          "checkbox" => %{
            "equals" => true
          }
        }
        ]
      }
    }

    data =
      KddNotionEx.Database.query(app.events_db, filter, app.account.access_token)
      |> Enum.map(&KddNotionEx.Transform.page_as_record/1)

    render(conn, :index, title: app.host_name, data: data, base_url: ~p"/apps/events/#{app.link}")
  end

  def index(conn, _params) do
    list = Kdd.Repo.all(Kdd.Apps.Events)

    render(conn, :browse, data: list)
  end

  def register(conn, %{"link" => link, "event_id" => event_id}) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: link) |> Kdd.Repo.preload(:account)

    event =
      KddNotionEx.Page.fetch(event_id, app.account.access_token)
      |> KddNotionEx.Transform.page_as_record()

    render(conn, :register, link: link, event: event, form: %{})
  end

  def signup(conn, %{"link" => link, "event_id" => event_id} = params) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: link) |> Kdd.Repo.preload(:account)

    %{"id" => signup_id} =
      Templates.new_page("Name", params["name"])
      |> Templates.add_property(Templates.relation_prop("Events", app.events_db, event_id))
      |> Templates.add_property(Templates.phone_number_prop("Phone number", params["phone"]))
      |> KddNotionEx.Page.create_record(app.signups_db, app.account.access_token)
      |> KddNotionEx.Page.decode_response()

    render(conn, :success, link: ~p"/apps/events/#{link}/signup/#{signup_id}")
  end

  def view_registration(conn, %{"link" => link, "signup_id" => signup_id}) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: link) |> Kdd.Repo.preload(:account)

    signup =
      KddNotionEx.Page.fetch(signup_id, app.account.access_token)
      |> KddNotionEx.Transform.page_as_record()

    render(conn, :signup, signup: signup)
  end

  def cancel_registration(conn, %{"link" => link, "signup_id" => signup_id}) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: link) |> Kdd.Repo.preload(:account)

    cancel = KddNotionEx.Templates.checkbox_prop("Cancelled", true)

    KddNotionEx.Page.update(signup_id, cancel, app.account.access_token)

    redirect(conn, to: ~p"/apps/events/#{link}/signup/#{signup_id}")
  end
end
