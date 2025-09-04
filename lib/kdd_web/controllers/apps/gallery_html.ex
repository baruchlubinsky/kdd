defmodule KddWeb.Apps.GalleryHTML do
  use KddWeb, :html

  embed_templates "gallery_html/*"

  slot :inner_block
  def container(assigns) do
    ~H"""
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-10">
      <.render_slot @inner_block />
    </div>
    """
  end

  attr :content, :map, required: true
  def card(assigns) do
    ~H"""
    <div class="rounded overflow-hidden shadow-lg flex flex-col">
      <.heading2><%= @content["Title"] %></.heading2>
      <.live_component module={KddWeb.CMSLive} id={@content["id"]} page_id={@content["id"]} />
    </div>
    """
  end
end
