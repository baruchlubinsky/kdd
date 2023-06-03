defmodule Kdd.Notion.Templates do

  def new_page(title_key, title_value) do
    %{title_key => %{type: "title", title: [%{type: "text", text: %{ content: title_value } }] }}
  end

  def add_property(page, property) do
    Map.merge(page, property)
  end

  def number_prop(key, value) when is_binary(value) do
    number =
    if String.contains?(value, ".") do
      String.to_float(value)
    else
      String.to_integer(value)
    end

    number_prop(key, number)
  end

  def number_prop(key, value) do
    %{
      key => %{
        type: "number",
        number: value
      }
    }
  end

  def datestamp(key) do
    %{
      key => %{
        type: "date",
        date: %{
          start: Date.to_iso8601(Date.utc_today)
        }
      }
    }
  end

  def relation_prop(key, database, value) do
    %{
      key => %{
        type: "relation",
        relation: [%{
          id: value,
          database_id: database
        }]
      }
    }
  end
end
