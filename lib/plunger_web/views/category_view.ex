defmodule PlungerWeb.CategoryView do
  use PlungerWeb, :view
  alias PlungerWeb.CategoryView
  alias Plunger.Categories
  alias Plunger.Categories.Category
  alias Plunger.Questions

  def name(%Category{} = category) do
    Categories.name(category)
  end

  def summary(%Category{} = category) do
    Categories.summary(category)
  end

  def truncated_summary(%Category{} = category) do
    summary = summary(category)
    if String.length(summary) > 100 do
      summary = summary |> String.slice(0, 100)
      summary <> "..."
    else
      summary
    end
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

  def num_questions(%Category{} = category) do
    category |> Categories.associated_questions() |> length()
  end

  def past_day_questions(%Category {} = category) do
      category
        |> Categories.associated_questions()
        |> Enum.filter(fn(question) -> Questions.is_under_one_day_old(question) end)
        |> length()
  end

  def past_week_questions(%Category {} = category) do
      category
        |> Categories.associated_questions()
        |> Enum.filter(fn(question) -> Questions.is_under_one_week_old(question) end)
        |> length()
  end

  def sort(categories, sort_by) do
    case sort_by do
      "questions" -> Enum.sort_by(categories, fn(category) ->
        num_questions(category) end) |> Enum.reverse()
      "date" -> Enum.sort_by(categories, &Categories.time_posted()/1, &PlungerWeb.ViewHelpers.naive_date_time_compare()/2) |> Enum.reverse()
      "name" -> Enum.sort_by(categories, fn(category) ->
        name(category) end)
      _ -> raise "This shouldn't happen"
    end
  end

  def sort_and_partition(categories, sort_by, num_elems_per_line) do
    categories
      |> sort(sort_by)
      |> Enum.chunk_every(3)
  end
end
