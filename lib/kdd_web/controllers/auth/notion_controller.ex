defmodule KddWeb.Auth.NotionController do
  use KddWeb, :controller

  def authenticate(conn, %{"code" => code}) do
    redirect = ~p"/auth/notion/authenticate"

    exchange_token(code, redirect)
    |> IO.inspect()

    resp(conn, 201, "")

  end

  def exchange_token(code, redirect) do
    basic_auth = Notion.Config.client_id() <> ":" <> Notion.Config.client_secret()
    body = oauth_token_params(code, redirect)

    headers = [
      {"Authorization", "Basic " <> Base.encode64(basic_auth)},
      {"Content-Type", "application/json"}
    ]

    Finch.build(:post, "https://api.notion.com/v1/oauth/token", headers, Jason.encode!(body))
    |> Finch.request(:notion_http)

  end

  def oauth_token_params(code, redirect) when not is_nil(redirect) do
    %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect
    }
  end

  def oauth_token_params(code, redirect) when is_nil(redirect) do
    %{
      grant_type: "authorization_code",
      code: code
    }
  end
end
