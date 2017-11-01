defmodule PlungerWeb.QuestionView do
  use PlungerWeb, :view
  alias Plunger.Repo
  alias Plunger.Questions.Question
  alias Plunger.Accounts
  alias Plunger.Responses.Response
  alias Plunger.Categories
  alias Plunger.Categories.Category
  alias Plunger.Comments.Comment
  alias Plunger.Questions.QuestionVote
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

  def list_categories() do
    Categories.list_categories()
  end

  def get_date_time(%Question{} = question) do
    question.inserted_at
  end

  def as_html(text) do
    text
    |> Earmark.as_html!()
    |> raw()
  end

  #def get_username(%Question{} = question) do
  #  user = Accounts.get_user!(question.user_id)
  #  user.username
  #end

  def get_name(%Question{} = question) do
    user = Accounts.get_user!(question.user_id)
    user.name
  end

  def get_num_votes(%Question{} = question) do
    sum = Repo.aggregate((from qv in QuestionVote, where: qv.question_id == ^question.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end
end
