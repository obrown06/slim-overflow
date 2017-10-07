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

  def get_responses(%Question{} = question) do
    query = (from r in Response,
              where: r.question_id == ^question.id,
              select: r)
      |> order_by_time_posted
      |> Repo.all

  end

  def get_comments(%Question{} = question) do
    query = (from c in Comment,
              where: c.question_id == ^question.id,
              select: c)
      |> order_by_time_posted
      |> Repo.all

  end

  def order_by_time_posted(query) do
    from t in query,
      order_by: t.inserted_at
  end
end
