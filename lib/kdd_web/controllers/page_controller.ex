defmodule KddWeb.PageController do
  use KddWeb, :controller
  import Ecto.Query

  def home(conn, _params) do
    render(conn, :home)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def kdd(conn, _params) do
    render(conn, :kdd)
  end

  def yoga(conn, _params) do
    app = Kdd.Repo.get_by!(Kdd.Apps.Events, link: "mwm") |> Kdd.Repo.preload(:account)

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

    render(conn, :yoga,
      contact: Application.get_env(:kdd, :yoga_email), data: data, base_url: ~p"/apps/events/#{app.link}"
    )
  end

  def consult(conn, _params) do
    session_token = conn.assigns[:kdd_token]

    if !session_token do
      render(conn, :consult,
        contact: Application.get_env(:kdd, :consulting_email),
        integration: Kdd.Notion.Config.auth_url()
      )
    else
      session =
        from(Kdd.Kdd.Session, where: [token: ^session_token], preload: :user)
        |> Kdd.Repo.one!()

      user = Kdd.Repo.preload(session.user, :notion_account)

      if is_nil(user.notion_account) do
        render(conn, :consult,
          contact: Application.get_env(:kdd, :consulting_email),
          integration: Kdd.Notion.Config.auth_url()
        )
      else
        render(conn, :notion_logged_in,
          contact: Application.get_env(:kdd, :consulting_email),
          workspace_name: user.notion_account.workspace_name
        )
      end
    end
  end
end
