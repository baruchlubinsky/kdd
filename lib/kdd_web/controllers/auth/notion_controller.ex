defmodule KddWeb.Auth.NotionController do
  use KddWeb, :controller
  import Ecto.Query

  @doc """
  This is the route set as the Notion Integration redirect URI

  https://developers.notion.com/docs/authorization#step-2-notion-redirects-the-user-to-the-integrations-redirect-uri-and-includes-a-code-parameter
  """
  def authenticate(conn, %{"code" => code}) do
    redirect = url(~p"/auth/notion/authenticate")

    case exchange_token(code, redirect) do
      {:ok, %{"workspace_id" => workspace_id} = data} ->
        account =
          Kdd.Repo.one(
            from(Kdd.Notion.Account, where: [workspace_id: ^workspace_id], preload: :user)
          )

        user =
          if is_nil(account) do
            user = Kdd.Repo.insert!(%Kdd.Kdd.User{})

            %Kdd.Notion.Account{user_id: user.id}
            |> Kdd.Notion.Account.changeset(data)
            |> Kdd.Repo.insert!()

            user
          else
            Kdd.Notion.Account.changeset(account, data)
            |> Kdd.Repo.update!()

            account.user
          end

        token = KddWeb.Auth.SessionController.new_token(user)

        # Remember me for 30 days
        put_resp_cookie(conn, "kdd_session", token, sign: true, max_age: 30 * 24 * 60 * 60)
        |> redirect(to: ~p"/notion")

      {:error, data} ->
        put_flash(conn, :error, data)
        |> redirect(to: ~p"/notion")
    end
  end

  def exchange_token(code, redirect) do
    basic_auth = Kdd.Notion.Config.client_id() <> ":" <> Kdd.Notion.Config.client_secret()
    body = oauth_token_params(code, redirect)

    headers = [
      {"Authorization", "Basic " <> Base.encode64(basic_auth)},
      {"Content-Type", "application/json"}
    ]

    Finch.build(:post, "https://api.notion.com/v1/oauth/token", headers, Jason.encode!(body))
    |> Finch.request!(Kdd.Finch)
    |> case do
      %Finch.Response{status: 200, body: body} -> {:ok, Jason.decode!(body)}
      %Finch.Response{body: body} -> {:error, Jason.decode!(body)}
    end
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
