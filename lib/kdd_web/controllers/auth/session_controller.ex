defmodule KddWeb.Auth.SessionController do
  import Plug.Conn
  use Phoenix.Controller, formats: [:html, :json], layouts: [html: KddWeb.Layouts]

  use Phoenix.VerifiedRoutes,
    endpoint: KddWeb.Endpoint,
    router: KddWeb.Router,
    statics: KddWeb.static_paths()

  import Ecto.Query

  def get_kdd_session(conn, _opts) do
    conn = fetch_cookies(conn, signed: ["kdd_session"])
    token = conn.cookies["kdd_session"] || false
    assign(conn, :kdd_token, token)
  end

  def load_user!(conn, _opts) do
    if token = conn.assigns[:kdd_token] do
      session = Kdd.Repo.one(from(Kdd.Kdd.Session, where: [token: ^token], preload: :user))

      if is_nil(session) do
        put_flash(conn, :error, "Session expired. Must be logged in.")
        |> logout(%{})
        |> halt()
      else
        user = Kdd.Repo.preload(session.user, :notion_account)

        if is_nil(user.notion_account) do
          put_flash(conn, :info, "Connect your Notion account to continue.")
          |> redirect(to: ~p"/notion")
          |> halt()
        end

        assign(conn, :user, user)
      end
    else
      put_flash(conn, :error, "Must be logged in.")
      |> redirect(to: ~p"/notion")
      |> halt()
    end
  end

  def logout(conn, _params) do
    delete_resp_cookie(conn, "kdd_session")
    |> redirect(to: ~p"/notion")
  end

  def new_token(user) do
    session =
      Kdd.Repo.one(from(Kdd.Kdd.Session, where: [user_id: ^user.id])) ||
        %Kdd.Kdd.Session{user_id: user.id}

    token = :crypto.strong_rand_bytes(8) |> Base.encode64(padding: false)

    Kdd.Kdd.Session.set_token(session, token)
    |> Kdd.Repo.insert_or_update!()

    token
  end

  def dev_token(conn, _params) do
    user = Kdd.Repo.one(Kdd.Kdd.User, preload: :session)

    token = new_token(user)

    # Remember me for 30 days
    put_resp_cookie(conn, "kdd_session", token, sign: true, max_age: 30 * 24 * 60 * 60)
    |> redirect(to: ~p"/notion")
  end
end
