defmodule KddWeb.WebhookController do
  use KddWeb, :controller
  require Logger

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

  def update_cms(conn, %{"data" => %{"properties" => params}}) do
    page_id = params["ID"]["formula"]["string"]
    Cachex.del(KddNotionEx.Cache.pages(), page_id)
    Cachex.del(KddNotionEx.Cache.content(), page_id)
    case KddWeb.PageController.download_routes() do
      {:ok, pages} ->
        routes =
        Enum.map(pages, fn page ->
          {page["Page URL"]["url"], page["ID"]["string"]}
        end)
        Cachex.put(:kdd, :cms_map, routes)
        if params["Published"]["checkbox"] do
          req = KddNotionEx.Client.new(Application.fetch_env!(:kdd_notion_ex, :cms_key))
          KddNotionEx.Page.fetch(req, page_id)
          KddNotionEx.Page.fetch_content(req, page_id)
        end
        send_resp(conn, 201, "")
      {:error, other} ->
        Logger.error(inspect other)
        send_resp(conn, 500, "")
    end

  end

end
