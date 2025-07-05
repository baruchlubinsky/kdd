defmodule KddWeb.PageHTML do
  use KddWeb, :html

  import KddWeb.Apps.EventsHTML

  embed_templates "page_html/*"
end
