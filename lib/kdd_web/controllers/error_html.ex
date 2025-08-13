defmodule KddWeb.ErrorHTML do
  use KddWeb, :html

  import KddWeb.ErrorBunny

  embed_templates "error_html/*"

end
