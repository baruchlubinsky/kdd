defmodule KddWeb.Apps.EventsHTML do
  use KddWeb, :html

  embed_templates "events_html/*"

  def event_row(assigns) do
    assigns = assign(assigns, :link, "#{assigns.base_url}/register/#{assigns.record["id"]}")
    ~H"""
    <div>

      <a href={@link}><%= @record["Name"] %> at <%= @record["Date"] %></a>
    </div>
    """
  end
end
