defmodule Kdd.Apps.Budget do
  use Kdd.Model

  schema "budget_apps" do
    belongs_to :account, Kdd.Notion.Account

    field :budget_db, :string
    field :expense_db, :string

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:budget_db, :expense_db])
    |> validate_required([:budget_db, :expense_db])
    |> validate_length(:budget_db, is: 32)
    |> validate_length(:expense_db, is: 32)
  end
end
