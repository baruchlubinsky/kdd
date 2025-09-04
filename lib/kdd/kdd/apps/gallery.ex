defmodule Kdd.Apps.Gallery do
  use Kdd.Model

  schema "gallery_apps" do
    belongs_to :account, Kdd.Notion.Account

    field :gallery_db, :string

    timestamps()
  end

  @doc false
  def changeset(app, attrs, req) do
    app
    |> cast(attrs, [:gallery_db])
    |> validate_required([:gallery_db])
    |> validate_change(:gallery_db, fn :gallery_db, value ->
      Kdd.Apps.GalleryDB.validate_notion_db(req, value)
      |> Enum.reject(fn a -> a == :ok end)
      |> Enum.map(fn {:error, msg} -> {:gallery_db, msg} end)
    end)
  end
end
