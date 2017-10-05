defmodule PlungerWeb.QuestionView do
  use PlungerWeb, :view
  alias Plunger.Repo
  alias Plunger.Posts.Question

  def get_categories(%Question{} = question) do
      question
      |> Ecto.assoc(:categories)
      |> Repo.all
      |> Enum.map(fn(category) -> category.name end)
      |> Enum.join(", ")
  end
end
