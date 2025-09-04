defmodule KddWeb.GalleryLive do
  use KddWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-10">
        <.card :for={page <- @gallery} content={page} token={@token} />
    </div>
    """
  end

  def mount(_params, %{"data" => data, "token" => token}, socket) do
    {:ok, assign(socket, [gallery: data, token: token])}
  end


  attr :content, :map, required: true
  attr :token, :string
  def card(assigns) do
    ~H"""
    <div class="rounded overflow-hidden shadow-lg flex flex-col">
      <.heading2><%= @content["Title"] %></.heading2>
      <.live_component module={KddWeb.CMSLive} id={@content["id"]} page_id={@content["id"]} token={@token} />
    </div>
    """
  end
end
