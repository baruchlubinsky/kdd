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
      },
      sorts: [%{
        "property" => "Date",
        "direction" => "ascending"
      }]
    }

    data =
    KddNotionEx.Client.new(app.account.access_token)
    |> KddNotionEx.Database.query(app.events_db, filter)
    |> Enum.map(&KddNotionEx.Transform.page_as_record/1)

    bio =
    KddNotionEx.Client.new(Application.get_env(:kdd_notion_ex, :cms_key))
    |> KddNotionEx.Page.fetch_content("24427dcec749804baca0feb49d6a5bb9")
    |> KddNotionEx.Page.elements()

    render(conn, :yoga,
      contact: Application.get_env(:kdd, :yoga_email), bio: bio, data: data, base_url: ~p"/apps/events/#{app.link}"
    )
  end

  def consult(conn, _params) do
    email = Application.get_env(:kdd, :consulting_email)
    render(conn, :consult, contact: email)
  end

  def apps(conn, _params) do
    session_token = conn.assigns[:kdd_token]
    email = Application.get_env(:kdd, :consulting_email)
    url = Kdd.Notion.Config.auth_url()

    if !session_token do
      render(conn, :apps,
        contact: email,
        integration: url,
        workspace_name: false
      )
    else
      session =
        from(Kdd.Kdd.Session, where: [token: ^session_token], preload: :user)
        |> Kdd.Repo.one!()

      user = Kdd.Repo.preload(session.user, :notion_account)

      if is_nil(user.notion_account) do
        render(conn, :apps,
          contact: email,
          integration: url,
          workspace_name: false
        )
      else
        render(conn, :apps,
          contact: email,
          integration: url,
          workspace_name: user.notion_account.workspace_name
        )
      end
    end
  end

end
