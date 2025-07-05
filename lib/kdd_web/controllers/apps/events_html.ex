defmodule KddWeb.Apps.EventsHTML do
  use KddWeb, :html

  embed_templates "events_html/*"

  attr :record, :map, required: true
  attr :link, :string, required: true
  attr :media, :string, default: "Poster"

  def event_row(assigns) do
    ~H"""
    <div>
      <.link href={@link}>
        <h2 class="text-xl">{@record["Name"]}</h2>
        {raw print_time(@record["Date"])}
      </.link>
    </div>
    <div :if={@media} >
      <%= for image <- @record[@media]["files"] do %>
      <.link href={@link}>
      <img src={image["file"]["url"]} alt={image["file"]["name"]} />
      </.link>
      <% end %>
    </div>
    """
  end

  attr :record, :map, required: true
  attr :link, :string, required: true
  attr :form, :map, default: %{}

  def signup_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@form} action={~p"/apps/events/#{@link}/signup"}>
      <.input field={f[:event_id]} type="hidden" value={@record["id"]} />
      <.input field={f[:name]} label="Your name" />
      <.input field={f[:phone]} label="Phone number" />
      <.button>Sign up</.button>
    </.simple_form>
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
