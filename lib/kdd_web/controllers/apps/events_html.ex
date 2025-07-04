defmodule KddWeb.Apps.EventsHTML do
  use KddWeb, :html

  embed_templates "events_html/*"

  def event_row(assigns) do
    assigns = assign(assigns, :link, "#{assigns.base_url}/register/#{assigns.record["id"]}")
    time = print_time(assigns.record["Date"])
    assigns = assign(assigns, :time, time)
    ~H"""
    <div>
      <a href={@link}><%= @record["Name"] %> at {raw @time}</a>
    </div>
    """
  end

  def print_time({st, et}) do
    "<span class=\"kdd_timestamp\" >#{st}</span> to <span class=\"kdd_timestamp\" >#{et}</span>"
  end

  def print_time(dt) do
    "<span class=\"kdd_timestamp\" >#{dt}</span>"
  end


  def host_link(assigns) do
    assigns = assign(assigns, :url, ~p"/apps/events/#{assigns.record.link}")

    ~H"""
    <a href={@url}><%= @record.host_name %></a>
    """
  end
end
