defmodule KddWeb.Apps.EventsHTML do
  use KddWeb, :html

  embed_templates "events_html/*"

  attr :record, :map, required: true
  attr :link, :string, required: true

  def event_row(assigns) do
    ~H"""
    <div>
      <a href={@link}>{@record["Name"]} at {raw print_time(@record["Date"])}</a>
    </div>
    <div :if={@record["Poster"]} >
      <%= for image <- @record["Poster"]["files"] do %>
      <img src={image["file"]["url"]} alt={image["file"]["name"]} />
      <% end %>
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
