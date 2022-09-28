defmodule KddWeb.KanbanController do
  use KddWeb, :controller
  import KddWeb.NotionController, only: [authenticate: 2]

  plug :authenticate, apps: [:kanban_app]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def settings(conn, _parmas) do
    user = conn.assigns[:notion_user]
    app = Kdd.KanbanApp.changeset(user.kanban_app)

    render(conn, "settings.html", kanban_app: app)
  end

  def configure(conn, %{"notion_app" => args}) do
    user = conn.assigns[:notion_user]
    app = user.notion_app

    source_db = Notion.API.get_database(args["ongoing_epics"], user.access_token)
    args = Map.put(args, "ongoing_prop_id", source_db["properties"][args["ongoing_prop"]]["id"])

    target_db = Notion.API.get_database(args["completed_epics"], user.access_token)
    args = Map.put(args, "completed_prop_id", target_db["properties"][args["completed_prop"]]["id"])

    if is_nil(app) do
      Kdd.KanbanApp.changeset(%Kdd.KanbanApp{user_id: user.id}, args)
      |> Kdd.Repo.insert()
    else
      Kdd.KanbanApp.changeset(app, args)
      |> Kdd.Repo.update()
    end
    |> case do
      {:ok, _app} -> redirect(conn, to: Routes.kanban_path(conn, :index))
      {:error, error} ->
        IO.inspect(error)
        redirect(conn, to: Routes.kanban_path(conn, :settings))
      end
  end

  def epic(conn, _params) do
    render(conn, "epic.html")
  end

  def complete_epic(conn, params) do
    user = conn.assigns[:notion_user]
    app = user.kanban_app

    %{"source" => src} = params
    %{"destination" => dest} = params

    Notion.Data.transfer_relation(src, app.ongoing_prop_id, dest, app.completed_prop_id, user.access_token)

    redirect(conn, to: Routes.kanban_path(conn, :index))
  end

end
