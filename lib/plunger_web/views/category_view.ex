defmodule PlungerWeb.CategoryView do
  use PlungerWeb, :view
  alias PlungerWeb.QuestionView
  alias Plunger.Categories
  alias Plunger.Categories.Category

  def name(%Category{} = category) do
    Categories.name(category)
  end

  def description(%Category{} = category) do
    Categories.description(category)
  end
end
