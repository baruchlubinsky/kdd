defmodule Kdd.Notion.Account do
  use Kdd.Model

  schema "notion_accounts" do
    belongs_to :user, Kdd.Kdd.User

    has_many :budget_apps, Kdd.Apps.Budget, foreign_key: :account_id
    has_many :events_apps, Kdd.Apps.Events, foreign_key: :account_id

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
