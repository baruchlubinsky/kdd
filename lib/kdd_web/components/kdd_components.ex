defmodule KddWeb.KddComponents do
  use Phoenix.Component

  slot :inner_block

  def center(assigns) do
    ~H"""
    <div class="flex">
    <div class="flex-auto"></div>
    <div class="flex-none">
      <%= render_slot(@inner_block) %>
    </div>
    <div class="flex-auto"></div>
    </div>
    """
  end

  slot :inner_block

  def heading(assigns) do
    ~H"""
    <.center>
      <h1 class="text-3xl font-semibold mb-4">
        <%= render_slot(@inner_block) %>
      </h1>
    </.center>
    """
  end

  slot :inner_block

  def heading2(assigns) do
    ~H"""
    <h2 class="text-2xl">
      <%= render_slot @inner_block %>
    </h2>
    """
  end

  def heading3(assigns) do
    ~H"""
    <h3 class="text-l font-bold">
      <%= render_slot @inner_block %>
    </h3>
    """
  end

  attr :href, :string, required: true
  attr :target, :string, default: "."
  slot :inner_block
  def hlink(assigns) do
    ~H"""
    <.link class="hover:underline" href={@href} target={@target}>
      <%= render_slot @inner_block %>
    </.link>
    """
  end

  slot :inner_block
  def cta(assigns) do
    ~H"""
    <p>
    <button class="bg-gray-600 hover:bg-gray-400 text-white font-bold py-2 px-4 rounded-full">
      <%= render_slot @inner_block %>
    </button>
    </p>
    """
  end

end
