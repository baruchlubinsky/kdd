defmodule Kdd.Repo.Migrations.CreateKanbanApps do
  use Ecto.Migration

  def up do
    create table("kanban_apps") do
      add :user_id, references("notion_users")
      add :completed_epics, :string
      add :completed_prop, :string
      add :completed_prop_id, :string
      add :ongoing_epics, :string
      add :ongoing_prop, :string
      add :ongoing_prop_id, :string

      timestamps()
    end
  end

  def down do
    drop table("kanban_apps")
  end
end
