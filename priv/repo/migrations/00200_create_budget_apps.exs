defmodule Kdd.Repo.Migrations.CreateBudgetApps do
  use Ecto.Migration

  def up do
    create table("budget_apps") do
      add :user_id, references("notion_users")
      add :expenses, :string
      add :categories, :string

      timestamps()
    end
  end

  def down do
    drop table("budget_apps")
  end
end
