defmodule Kdd.Notion.Config do

  def get_setting(name) do
    Application.get_env(:kdd, :notion) |> Keyword.get(name)
  end

  def auth_url() do
    get_setting(:auth_url)
  end

  def client_id() do
    get_setting(:client_id)
  end

  def client_secret() do
    get_setting(:client_secret)
  end

end
