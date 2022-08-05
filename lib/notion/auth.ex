defmodule Notion.Auth do
  import Notion.API

  def auth_url(client_id, redirect) do
    args =
    [
      client_id: client_id,
      redirect_uri: redirect,
      response_type: "code",
      owner: "user"
    ]
    |> URI.encode_query()

    "https://api.notion.com/v1/oauth/authorize?" <> args
  end

  def exchange_token(client_id, client_secret, code, redirect) do
    auth = client_id <> ":" <> client_secret
    body = %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect
    }

    oauth_token(auth, body)
  end
end
