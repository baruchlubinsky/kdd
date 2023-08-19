defmodule KddWeb.Apps.EventsHTML do
  use KddWeb, :html

  embed_templates "events_html/*"

  def event_row(assigns) do
    assigns = assign(assigns, :link, "#{assigns.base_url}/register/#{assigns.record["id"]}")
    ~H"""
    <div>
      <%= inspect(@record) %>
      <a href={@link}>Register</a>
    </div>
    """
  end
end
