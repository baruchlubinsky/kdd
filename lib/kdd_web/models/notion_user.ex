defmodule Kdd.NotionUser do
  use Ecto.Schema

  schema "notion_users" do
    field :bot_id, :string
    field :access_token, :string
    field :workspace_id, :string
    field :workspace_name, :string

    has_one :budget_app, Kdd.BudgetApp, foreign_key: :user_id

    timestamps()
  end

  def create(params) do
    Ecto.Changeset.cast(%Kdd.NotionUser{}, params, [:bot_id, :access_token, :workspace_id, :workspace_name])
  end

  def update(object, params) do
    Ecto.Changeset.cast(object, params, [:access_token, :workspace_id, :workspace_name])
  end
end
