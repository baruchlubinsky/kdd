defmodule Kdd.Apps.Budget do
  use Kdd.Model

  schema "budget_apps" do
    belongs_to :account, Kdd.Notion.Account

    field :budget_db, :string
    field :expense_db, :string

    timestamps()
  end

  @doc false
  def changeset(app, attrs, req) do
    app
    |> cast(attrs, [:budget_db, :expense_db])
    |> validate_required([:budget_db, :expense_db])
    |> validate_length(:budget_db, is: 32)
    |> validate_length(:expense_db, is: 32)
    |> validate_change(:budget_db, fn :budget_db, value ->
      Kdd.Apps.BudgetDB.validate_notion_db(req, value)
      |> Enum.reject(fn a -> a == :ok end)
      |> Enum.map(fn {:error, msg} -> {:budget_db, msg} end)
    end)
  end
end
