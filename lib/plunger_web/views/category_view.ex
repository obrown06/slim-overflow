defmodule PlungerWeb.CategoryView do
  use PlungerWeb, :view
  alias PlungerWeb.CategoryView
  alias Plunger.Categories
  alias Plunger.Categories.Category

  def name(%Category{} = category) do
    Categories.name(category)
  end

  def summary(%Category{} = category) do
    Categories.summary(category)
  end

  def long_summary(%Category{} = category) do
    Categories.long_summary(category)
  end

  def time_posted(%Category{} = category) do
    Categories.time_posted(category) |> PlungerWeb.ViewHelpers.format_time()
  end

  def time_updated(%Category{} = category) do
    Categories.time_updated(category) |> PlungerWeb.ViewHelpers.format_time()
  end

  def num_category_views(%Category{} = category) do
    category |> Categories.list_category_views() |> length()
  end
end
