defmodule Kdd.Apps.ExpenseDB do
  use KddNotionEx.CMS.Model

  schema "Expenses" do
    field :"Name", :string
    field :"Amount", :integer
    field :"Date", :date

    has_one :"Category", Kdd.Apps.BudgetDB, foreign_key: :"Category"

    field :categories_id, :string, virtual: true

  end
end
