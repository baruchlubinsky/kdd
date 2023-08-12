defmodule Kdd.Repo.Migrations.CreateEventsApps do
  use Ecto.Migration

  def change do
    create table(:events_apps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references("notion_accounts", type: :binary_id)

      add :events_db, :string, size: 32
      add :signups_db, :string, size: 32

      add :link, :string
      add :host_name, :string

      timestamps()
    end
  end
end
