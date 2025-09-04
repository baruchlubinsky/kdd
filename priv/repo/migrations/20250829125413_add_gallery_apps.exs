defmodule Kdd.Repo.Migrations.AddGalleryApps do
  use Ecto.Migration

  def change do
    create table(:gallery_apps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references("notion_accounts", type: :binary_id)

      add :gallery_db, :string, size: 32

      timestamps()
    end
  end
end
