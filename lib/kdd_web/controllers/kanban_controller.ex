defmodule KddWeb.KanbanController do
  use KddWeb, :controller
  import KddWeb.NotionController, only: [authenticate: 2]

  plug :authenticate, apps: [:kanban_app]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def settings(_conn, _params) do

  end

  def configure(_conn, _params) do

  end

  def epic(conn, _params) do
    render(conn, "epic.html")
  end

  def complete_epic(conn, params) do
    user = conn.assigns[:notion_user]

    %{"source" => epic} = params
    %{"destination" => dest} = params

    Notion.API.get_page(epic, user.access_token)
  end

  def transfer_relation(src_page, src_prop, dest_page, dest_prop, access_token) do
    relation = Notion.API.get_page_property(src_page, src_prop, access_token)
    values = Enum.map(relation, &Map.get(&1, "relation"))
    properties = %{
      "properties" => %{
        dest_prop => values
      }
    }
    Notion.API.update_page(dest_page, properties, access_token)
  end

end
