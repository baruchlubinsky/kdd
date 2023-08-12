defmodule KddWeb.Apps.EventsHTML do
  use KddWeb, :html

  embed_templates "events_html/*"

  def event_row(assigns) do
    ~H"""
    <div>
      <%= inspect(@record) %>
    </div>
    """
  end
end
