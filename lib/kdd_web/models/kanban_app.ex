defmodule Kdd.KanbanApp do
  use Ecto.Schema

  schema "kanban_apps" do
    belongs_to :user, Kdd.NotionUser
    field :completed_epics, :string
    timestamps()
  end

  def changeset(object, params \\ %{}) do
    Ecto.Changeset.cast(object, params, [:completed_epics])
  end
end
