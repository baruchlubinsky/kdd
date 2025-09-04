defmodule Kdd.Apps.BudgetDB do
  use KddNotionEx.CMS.Model

  schema "Budget" do
    field :"Category", :string
    field :"Amount", :integer

    belongs_to :"Expenses", Kdd.Apps.ExpenseDB

  end
end
