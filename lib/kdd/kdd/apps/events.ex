defmodule Kdd.Apps.Events do
  use Kdd.Model

  schema "events_apps" do
    belongs_to :account, Kdd.Notion.Account

    field :events_db, :string
    field :signups_db, :string

    field :events_name, :string

    field :host_name, :string
    field :link, :string

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:events_db, :events_name, :signups_db, :host_name, :link])
    |> validate_required([:events_db, :signups_db, :host_name, :link])
    |> validate_length(:events_db, is: 32)
    |> validate_length(:events_db, is: 32)
  end
end
