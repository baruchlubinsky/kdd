defmodule KddWeb.KddComponents do
  use Phoenix.Component

  slot :inner_block

  def heading(assigns) do
    ~H"""
    <div class="flex space-between">
      <div class="flex-grow w-auto">
        <h1 class="text-2xl font-semilbold">
          <%= render_slot(@inner_block) %>
        </h1>
      </div>
    </div>
    """
  end

end
