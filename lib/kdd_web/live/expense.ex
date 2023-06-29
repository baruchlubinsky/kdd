defmodule KddWeb.LiveExpense do
  use KddWeb, :live_view

  def mount(_params, session, socket) do
    # fetch categories async
    {:ok, assign(socket, categories: [])}
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={%{}} as={:expense} phx-submit="save">
    <.input type="text" label="Title" name="name" value="" />
    <.input type="select" label="Category" name="category" options={@categories} value="" />
    <.input type="number" label="Amount" name="amount" value="" />
    <.button>Save</.button>
    </.simple_form>
    """
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

end
