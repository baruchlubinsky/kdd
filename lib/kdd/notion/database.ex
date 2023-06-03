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

  def query(database_id, query, token) do
    payload = if is_nil(query) do
      nil
    else
      Jason.encode!(query)
    end

    response =
    Finch.build(:post, "https://api.notion.com/v1/databases/#{database_id}/query", headers(token), payload)
    |> Finch.request!(:notion_http)
    |> case do
      %Finch.Response{status: 200, body: body} ->
        Jason.decode!(body)
    end
    if response["has_more"] do
      query = query || %{}
        |> Map.put("start_cursor", response["next_cursor"])
      response["results"] ++ query(database_id, query, token)
    else
      response["results"]
    end
  end
end
