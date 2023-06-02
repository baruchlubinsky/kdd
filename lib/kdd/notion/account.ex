defmodule Kdd.Notion.Account do
  use Kdd.Model

  schema "notion_accounts" do
    belongs_to :user, Kdd.Kdd.User

    field :access_token, :string
    field :bot_id, :string
    field :workspace_name, :string
    field :workspace_id, :string

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:access_token, :bot_id, :workspace_name, :workspace_id])
    |> validate_required([:workspace_id])
  end
end
