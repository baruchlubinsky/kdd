defmodule Kdd.Repo.Migrations.CreateNotionUsers do
  use Ecto.Migration

  def up do
    create table("notion_users") do
      add :bot_id, :string
      add :access_token, :string
      add :workspace_id, :string
      add :workspace_name, :string

      timestamps()
    end
  end

  def down do
    drop table("notion_users")
  end
end
