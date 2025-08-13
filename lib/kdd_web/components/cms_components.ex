defmodule KddWeb.CMSComponents do
  use Phoenix.Component

  attr :element, :any, required: true
  def render_element(%{element: text} = assigns) when is_binary(text) do
    ~H"{@element}"
  end

  def render_element(%{element: elements} = assigns) when is_list(elements) do
    assigns = assign(assigns, :elements, elements)
    ~H"""
    <.render_element :for={e <- @elements} element={e} />
    """
  end

  def render_element(%{element: {elements}} = assigns) when is_list(elements) do
    render_element(assign(assigns, :element, elements))
  end

  def render_element(%{element: {:h1, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    ~H"""
    <.heading>
      <.render_element element={@content} />
    </.heading>
    """
  end

  def render_element(%{element: {:h2, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    ~H"""
    <.heading2>
      <.render_element element={@content} />
    </.heading2>
    """
  end

  def render_element(%{element: {:h3, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    ~H"""
    <.heading3>
      <.render_element element={@content} />
    </.heading3>
    """
  end

  def render_element(%{element: {:s, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    ~H"""
    <.span>
      <.render_element element={@content} />
    </.span>
    """
  end

  def render_element(%{element: {:p, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    ~H"""
    <.paragraph>
      <.render_element element={@content} />
    </.paragraph>
    """
  end

  def render_element(%{element: {:cta, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    ~H"""
    <.cta>
      <.render_element element={@content} />
    </.cta>
    """
  end

  def render_element(%{element: {:a, href, content}} = assigns) do
    assigns = assign(assigns, :content, content)
    assigns = assign(assigns, :href, href)

    ~H"""
    <.link href={@href}>
      <.render_element element={@content} />
    </.link>
    """
  end

  def render_element(%{element: {:image, url, alt}} = assigns) do
    assigns = assign(assigns, :url, url)
    assigns = assign(assigns, :alt, alt)

    ~H"""
    <.image url={@url} alt={@alt} />
    """
  end

  def render_element(%{element: {:li, content}} = assigns) do
    assigns = assign(assigns, :content, content)

    ~H"""
    <li class="ml-4">
      <.render_element element={@content} />
    </li>
    """
  end

  def render_element(assigns) do
    ~H"<!-- Unknown element -->"
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
  def paragraph(assigns) do
    ~H"""
    <p>
      <%= render_slot @inner_block %>
    </p>
    """
  end

  slot :inner_block
  def span(assigns) do
    ~H"""
    <span>
      <%= render_slot @inner_block %>
    </span>
    """
  end

  attr :url, :string, required: true
  attr :alt, :string, default: ""
  def image(assigns) do
    ~H"""
    <img src={@url} alt={@alt} />
    """
  end



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
