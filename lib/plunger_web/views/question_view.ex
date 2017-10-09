defmodule PlungerWeb.QuestionView do
  use PlungerWeb, :view
  alias Plunger.Repo
  alias Plunger.Posts.Question
  alias Plunger.Accounts
  alias Plunger.Posts.Response
  alias Plunger.Posts.Comment
  import Ecto.Query, only: [from: 2]

  def get_categories(%Question{} = question) do
      question
      |> Ecto.assoc(:categories)
      |> Repo.all
  end

  def list_categories(%Question{} = question) do
    get_categories(question)
    |> Enum.map(fn(category) -> category.name end)
    |> Enum.join(", ")
  end

  def get_date_time(%Question{} = question) do
    question.inserted_at
  end

  def get_username(%Question{} = question) do
    user = Accounts.get_user!(question.user_id)
    user.username
  end
end
