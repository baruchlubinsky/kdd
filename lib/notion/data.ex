defmodule Notion.Data do

  def table_to_options(data, column) do
    Enum.map(data, fn %{"id" => id, "properties" => %{^column => %{"title" => [%{"plain_text" => c}]}}} -> {c, id} end)
  end

end
