defmodule Kdd.Repo.Migrations.AddEventsName do
  use Ecto.Migration

  def change do
    alter table(:events_apps) do
      add :events_name, :string
    end
  end
end
