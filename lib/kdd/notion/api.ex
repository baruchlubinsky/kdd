defmodule Kdd.Notion.Api do

  def headers(token) do
    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Notion-Version", "2022-06-28"}
    ]
  end


end
