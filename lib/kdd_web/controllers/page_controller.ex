defmodule KddWeb.PageController do
  require Logger
  use KddWeb, :controller
  import Ecto.Query

  def download_routes() do
    cms_db = Application.fetch_env!(:kdd, :cms_db)
    req = KddNotionEx.Client.new(Application.fetch_env!(:kdd_notion_ex, :cms_key))
    filter = %{
      filter:
        %{
          "property" => "Published",
          "checkbox" => %{
            "equals" => true
          }
        },
      sorts: [%{

        "property" => "Page URL",
        "direction" => "ascending"
      }]
    }

    Req.post(req, url: "/databases/#{cms_db}/query", json: filter)
    |> case do
      {:ok, %Req.Response{status: 200, body: response}} ->
        if response["has_more"] do
            query = filter
              |> Map.put("start_cursor", response["next_cursor"])
            response["results"] ++ KddNotionEx.Database.query_page(req, cms_db, query)
        else
          {:ok, Enum.map(response["results"], &KddNotionEx.Transform.page_as_record/1)}
        end
      {:ok, other} ->
        Logger.error(inspect other)
        {:error, []}
      {:error, exception} ->
        raise exception
    end

  end

  def cms_map() do

    # [:ok, :ok, :ok] = KddNotionEx.CMS.Config.validate_notion_db(req, cms_db)

    Cachex.fetch!(:kdd, :cms_map, fn _ ->
      # return a empty list but don't crash on an HTTP error
      {_, pages} = download_routes()
      Enum.map(pages, fn page ->
        {page["Page URL"]["url"], page["ID"]["string"]}
      end)
    end
    )
  end

  def check_route(conn, _params) do
    id = cms_id(conn.request_path)

    if is_nil(id) do
      put_status(conn, 404)
      |> halt()
    else
      conn
    end
  end

  def cms_id(path) do
    {_, id} =
    Enum.find(cms_map(), {nil, nil}, fn {route, _id} ->
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

  def cms(conn, %{"cms_path" => path}) do
    id = cms_id("/#{Enum.join(path, "/")}")

    if is_nil(id), do: raise(Phoenix.Router.NoRouteError, conn: conn, router: KddWeb.Router)

    page =
    KddNotionEx.Client.new(Application.get_env(:kdd_notion_ex, :cms_key))
    |> KddNotionEx.Page.fetch_content(id)
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
