defmodule Kdd.Apps.GalleryDB do
  use KddNotionEx.CMS.Model

  schema "Expenses" do
    field :"Title", KddNotionEx.Types.Title
    field :"Date", :date
    field :"Tags", KddNotionEx.Types.MultiSelect

  end
end
