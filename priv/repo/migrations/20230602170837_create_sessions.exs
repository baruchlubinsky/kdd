defmodule Kdd.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references("users", type: :binary_id)

      add :token, :string

      timestamps()
    end

    create index("sessions", [:token])
  end
end
