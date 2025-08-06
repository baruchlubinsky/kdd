defmodule KddWeb.PageController do
  use KddWeb, :controller
  import Ecto.Query

  def cms_map() do
    [
      {"/", "24727dcec7498023af20e880ea978872"},
      {"/yoga", "24427dcec749804baca0feb49d6a5bb9"},
      {"/consult", "24727dcec7498008b400f287f2106d3b"},
      {"/kdd", "24727dcec7498058bc90ff3898e90725"},
      {"/about", "24727dcec7498021a9f8e71f02582292"}
    ]
  end

  def cms_id(path) do
    {_, id} =
    Enum.find(cms_map(), fn {route, _id} ->
      route == path
    end)
    id
  end

  def cms_path(id) do
    {route, _id} =
    Enum.find(cms_map(), {id, nil},
    fn {_route, page_id} ->
      "/#{page_id}" == id
    end
    )
    route
  end

  def cms(conn, _params) do
    page =
    KddNotionEx.Client.new(Application.get_env(:kdd_notion_ex, :cms_key))
    |> KddNotionEx.Page.fetch_content(cms_id(conn.request_path))
    |> KddNotionEx.Page.elements(paths: &cms_path/1)

    render(conn, :cms, page: page)
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
    |> KddNotionEx.Page.fetch_content(cms_id("/yoga"))
    |> KddNotionEx.Page.elements(paths: &cms_path/1)

    render(conn, :yoga,
      contact: Application.get_env(:kdd, :yoga_email), bio: bio, data: data, base_url: ~p"/apps/events/#{app.link}"
    )
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

  def notion(conn, _) do
    redirect(conn, to: "/consult")
  end

end
