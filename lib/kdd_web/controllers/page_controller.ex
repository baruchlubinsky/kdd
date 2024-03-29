defmodule KddWeb.PageController do
  use KddWeb, :controller
  import Ecto.Query

  def home(conn, _params) do
    render(conn, :home)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def notion(conn, _params) do
    session_token = conn.assigns[:kdd_token]

    if !session_token do
      render(conn, :notion, contact: "mailto:#{Application.get_env(:kdd, :contact_email)}", integration: Kdd.Notion.Config.auth_url())
    else
      session =
        from(Kdd.Kdd.Session, where: [token: ^session_token], preload: :user)
        |> Kdd.Repo.one!()

      user = Kdd.Repo.preload(session.user, :notion_account)

      if is_nil(user.notion_account) do
        render(conn, :notion, contact: "mailto:#{Application.get_env(:kdd, :contact_email)}", integration: Kdd.Notion.Config.auth_url())
      else
        render(conn, :notion_logged_in, contact: "mailto:#{Application.get_env(:kdd, :contact_email)}", workspace_name: user.notion_account.workspace_name)
      end
    end
  end
end
