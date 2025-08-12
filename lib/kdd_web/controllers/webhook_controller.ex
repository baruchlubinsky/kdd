defmodule KddWeb.WebhookController do
  use KddWeb, :controller

  def check_secret(conn, _params) do
    [secret] = get_req_header(conn, "x-kdd-secret")
    if Application.fetch_env!(:kdd, :notion_webhook_secret) == secret do
      conn
    else
      put_status(conn, 403)
      |> send_resp()
      |> halt()
    end
  end

  def update_cms(conn, %{"data" => %{"properties" => _params}}) do

    send_resp(conn, 201, "")
  end

end
