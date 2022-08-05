defmodule KddWeb.NotionController do
  use KddWeb, :controller
  import Ecto.Query

  plug :authenticate when action in [:index]

  def client_id(), do: Application.fetch_env!(:kdd, :notion) |> Keyword.fetch!(:client_id)
  def client_secret(), do: Application.fetch_env!(:kdd, :notion) |> Keyword.fetch!(:client_secret)
  def redirect_url(conn), do: Routes.notion_url(conn, :callback)

  def authenticate(conn, options \\ []) do
    user_id = get_session(conn, :notion)
    if is_nil(user_id) do
      redirect(conn, to: Routes.notion_path(conn, :login))
      |> halt()
    else
      apps = Keyword.get(options, :apps, [])
      user = Kdd.Repo.one(from u in Kdd.NotionUser, where: u.bot_id == ^user_id, preload: ^apps)
      assign(conn, :notion_user, user)
    end
  end

  def login(conn, _params) do
    url = Notion.Auth.auth_url(client_id(), redirect_url(conn))
    render(conn, "login.html", auth_url: url)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def callback(conn, %{"code" => code, "state" => _state}) do
    params =
    Notion.Auth.exchange_token(client_id(), client_secret(), code, redirect_url(conn))

    existing = Kdd.Repo.get_by(Kdd.NotionUser, bot_id: params["bot_id"])
    if is_nil(existing) do
      Kdd.NotionUser.create(params)
      |> Kdd.Repo.insert()
    else
      Kdd.NotionUser.update(existing, params)
      |> Kdd.Repo.update()
    end
    |> case do
      {:ok, user} ->
        put_session(conn, :notion, user.bot_id)
        |> render("index.html")
      {:error, changeset} ->
        IO.inspect(changeset)
        put_flash(conn, :error, "Something went wrong while connecting to Notion.")
        |> render("index.html")
      end
  end

end
