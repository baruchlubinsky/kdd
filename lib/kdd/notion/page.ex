defmodule Kdd.Notion.Page do
  import Kdd.Notion.Api

  def get(page_id, token) do
    Finch.build(:get, "https://api.notion.com/v1/pages/#{page_id}", headers(token))
    |> Finch.request!(:notion_http)
  end

  def create_record(properties, database_id, token) do
    payload = %{
      parent: %{database_id: database_id},
      properties: properties
    }
    Finch.build(:post, "https://api.notion.com/v1/pages", headers(token), Jason.encode!(payload))
    |> Finch.request!(:notion_http)
  end
end
