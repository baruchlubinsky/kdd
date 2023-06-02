defmodule Kdd.Repo.Migrations.CreateNotionAccounts do
  use Ecto.Migration

  def change do
    create table(:notion_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references("users", type: :binary_id)

      add :access_token, :string
      add :bot_id, :string
      add :workspace_name, :string
      add :workspace_id, :string

      timestamps()
    end
  end
end
