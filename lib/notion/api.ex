defmodule Notion.API do

  def connect!() do
    {:ok, conn} = Mint.HTTP.connect(:https, "api.notion.com", 443)
    conn
  end

  defp headers(token) when not is_nil(token) do
    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Notion-Version", "2021-08-16"}
    ]
  end

  defp headers(token) when is_nil(token) do
    headers(System.fetch_env!("NOTION_TOKEN"))
  end

  def oauth_token(basic_auth, body) do
    payload = Jason.encode!(body)
    headers = [
      {"Authorization", "Basic " <> Base.encode64(basic_auth)},
      {"Content-Type", "application/json"}
    ]

    {:ok, conn, request_ref} =
      connect!()
      |> Mint.HTTP.request("POST", "/v1/oauth/token", headers, payload)

    read_response(conn, request_ref)
    |> Map.get(:data)
  end

  def create_page(properties, parent_id, auth_token) do
    payload =
    %{
      parent: %{
          type: "database_id",
          database_id: parent_id,
      },
      properties: properties,
    }
    |> Jason.encode!()

    {:ok, conn, request_ref} =
      connect!()
      |> Mint.HTTP.request("POST", "/v1/pages", headers(auth_token), payload)

    read_response(conn, request_ref)
    |> Map.get(:data)
  end

  def fetch_table(id, auth_token), do: fetch_table(id, nil, auth_token)

  def fetch_table(id, query, auth_token) do
    payload =
      if is_nil(query) do
        query
      else
        Jason.encode!(query)
      end

    {:ok, conn, request_ref} =
      connect!()
      |> Mint.HTTP.request("POST", Path.join(["/v1/databases/",id,"/query"]), headers(auth_token), payload)

    %{data: resp} = read_response(conn, request_ref)
    case resp do
      %{"has_more" => true} ->
        query = query || %{}
          |> Map.put("start_cursor", resp["next_cursor"])
        resp["results"] ++ fetch_table(id, query, auth_token)
      _ ->
        resp["results"]
    end
  end

  def read_response(conn, request_ref) do
    receive do
      message ->

      conn =
      case Mint.HTTP.stream(conn, message) do
        {:ok, conn, responses} when is_list(responses) ->
          Enum.reduce(responses, conn,
          fn {:status, _ref, status}, conn ->
              Map.put(conn, :status, status)
             {:headers, _ref, _headers}, conn ->
              conn
             {:data, _ref, ""}, conn ->
              conn
             {:data, _ref, chunk}, conn ->
              Map.update(conn, :binary_data, chunk, fn data -> data <> chunk end)
             {:done, _ref}, conn ->
              {:ok, conn} = Mint.HTTP.close(conn)
              conn
             {:error, _ref, error}, conn ->
              IO.inspect(error)
              conn
          end)
        :unknown ->
          IO.puts("Unknown response")
          {:ok, conn} = Mint.HTTP.close(conn)
          conn
      end

      if Mint.HTTP.open?(conn) do
        read_response(conn, request_ref)
      else
        body = Map.get(conn, :binary_data)
        unless body == "" do
          Map.put(conn, :data, Jason.decode!(body))
        else
          conn
        end
      end

    end
  end

end
