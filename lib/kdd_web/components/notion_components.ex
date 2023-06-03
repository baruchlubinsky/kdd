defmodule KddWeb.NotionComponents do
  use Phoenix.Component

  def link_input(assigns) do
    ~H"""
    <input class="notionLink border rounded" id={@id} type="text" size="40" placeholder="Paste a Notion link" />
    """
  end
end
