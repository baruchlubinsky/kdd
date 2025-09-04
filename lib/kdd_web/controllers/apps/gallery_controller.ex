defmodule KddWeb.Apps.GalleryController do
  use KddWeb, :controller
  import Phoenix.LiveView.Controller
  import Ecto.Query

  alias KddNotionEx.Templates

  plug :load_user!

  def settings(conn, _params) do
    user = conn.assigns[:user]

    record =
      Kdd.Repo.one(from(Kdd.Apps.Gallery, where: [account_id: ^user.notion_account.id])) ||
        %Kdd.Apps.Gallery{}

    render(conn, :settings, form: Ecto.Changeset.change(record))
  end

  def configure(conn, params) do
    user = conn.assigns[:user]

    record =
      Kdd.Repo.one(from(Kdd.Apps.Gallery, where: [account_id: ^user.notion_account.id])) ||
        %Kdd.Apps.Gallery{account_id: user.notion_account.id}

    req = KddNotionEx.Client.new(user.notion_account.access_token)

    record
    |> Kdd.Apps.Gallery.changeset(params["gallery"], req)
    |> Kdd.Repo.insert_or_update()
    |> case do
      {:ok, _} ->
        put_flash(conn, :info, "Saved.")
        |> redirect(to: ~p{/apps/gallery})
      {:error, other} ->
        render(conn, :settings, form: other)
    end
  end

  def index(conn, _params) do
    user = conn.assigns[:user]
    app = Kdd.Repo.one(from(Kdd.Apps.Gallery, where: [account_id: ^user.notion_account.id]))

    if is_nil(app) or is_nil(app.gallery_db) do
      redirect(conn, to: ~p"/apps/gallery/settings")
    else
      gallery =
      KddNotionEx.Client.new(user.notion_account.access_token)
      |> KddNotionEx.Database.query_live(app.gallery_db)
      |> Enum.map(&KddNotionEx.Transform.page_as_record/1)

      live_render(conn, KddWeb.GalleryLive, session: %{"data" => gallery, "token" => user.notion_account.access_token})
    end
  end


end
