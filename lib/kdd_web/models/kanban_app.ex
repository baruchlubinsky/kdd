defmodule Kdd.KanbanApp do
  use Ecto.Schema

  schema "kanban_apps" do
    belongs_to :user, Kdd.NotionUser
    field :completed_epics, :string
    field :completed_prop, :string
    field :completed_prop_id, :string
    field :ongoing_epics, :string
    field :ongoing_prop, :string
    field :ongoing_prop_id, :string
    timestamps()
  end

  def changeset(object, params \\ %{}) do
    Ecto.Changeset.cast(object, params, [:completed_epics, :completed_prop, :completed_prop_id, :ongoing_epics, :ongoing_prop, :ongoing_prop_id])
  end
end
