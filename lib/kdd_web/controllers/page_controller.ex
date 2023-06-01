defmodule KddWeb.PageController do
  use KddWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def notion(conn, _params) do
    render(conn, :notion, contact: "mailto:#{Application.get_env(:kdd, :contact_email)}")
  end
end
