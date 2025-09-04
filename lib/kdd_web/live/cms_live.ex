defmodule KddWeb.CMSLive do
  use KddWeb, :live_component

  attr :page_id, :string, required: true
  attr :token, :string, required: true
  def render(assigns) do
    ~H"""
    <div>
    <.async_result :let={content} assign={@content}>
      <:loading><.loading_spinner /></:loading>
      <:failed :let={_failure}>there was an error loading the content</:failed>
      <.render_element element={content} />
    </.async_result>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, :content, Phoenix.LiveView.AsyncResult.loading())}
  end

  def update(%{page_id: page_id, token: token} = _assigns, socket) do
    {:ok,
      assign_async(socket, :content, fn ->
        {:ok, %{content: load_page_content(token, page_id)}}
      end)
    }
  end

  def load_page_content(token, page_id) do
    KddNotionEx.Client.new(token)
    |> KddNotionEx.Page.fetch_content(page_id)
    |> KddNotionEx.Page.elements(paths: &KddWeb.PageController.cms_path/1)
  end
end
