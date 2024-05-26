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


  def host_link(assigns) do
    assigns = assign(assigns, :url, ~p"/apps/events/#{assigns.record.link}")

    ~H"""
    <a href={@url}><%= @record.host_name %></a>
    """
  end
end
