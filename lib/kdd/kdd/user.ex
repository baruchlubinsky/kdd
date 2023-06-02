defmodule Kdd.Kdd.User do
  use Kdd.Model

  schema "users" do
    has_one :session, Kdd.Kdd.Session

    has_one :notion_account, Kdd.Notion.Account

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
