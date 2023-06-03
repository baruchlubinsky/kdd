defmodule Kdd.Notion.Database do
  import Kdd.Notion.Api

  def get_properties(database_id, token) do
    Finch.build(:get, "https://api.notion.com/v1/databases/#{database_id}", headers(token))
    |> Finch.request!(:notion_http)
    |> case do
      %Finch.Response{status: 200, body: body} ->
        response = Jason.decode!(body)
        response["properties"]
    end

  end
end
