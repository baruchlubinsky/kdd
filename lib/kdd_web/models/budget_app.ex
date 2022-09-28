defmodule Kdd.BudgetApp do
  use Ecto.Schema

  schema "budget_apps" do
    belongs_to :user, Kdd.NotionUser
    field :expenses, :string
    field :categories, :string
    timestamps()
  end

  def changeset(object, params \\ %{}) do
    Ecto.Changeset.cast(object, params, [:expenses, :categories])
  end
end
