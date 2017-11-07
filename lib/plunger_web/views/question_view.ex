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
  alias Plunger.Questions.QuestionView
  alias Plunger.Questions
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

  def sort(questions, sort_by) do
    case sort_by do
      nil -> questions
      "votes" -> Enum.sort_by(questions, &get_num_votes(&1)) |> Enum.reverse()
      "responses" -> Enum.sort_by(questions, fn(question) ->
        length(Repo.all(from r in Response, where: r.question_id == ^question.id)) end) |> Enum.reverse()
      "date" -> Enum.sort_by(questions, fn(question) -> question.inserted_at end) |> Enum.reverse()
      "views" -> Enum.sort_by(questions, fn(question) ->
        length(Repo.all(from qv in QuestionView, where: qv.question_id == ^question.id)) end) |> Enum.reverse()
      _ -> raise "This shouldn't happen"
    end
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

  def get_questions(categories) do
    case categories do
      "all" -> Questions.list_questions()
      boolean_list ->
        boolean_list
        |> Enum.filter(fn(elem) -> elem != "" end)
        |> Enum.reduce([], fn({category_id, value}, acc) ->
            if value == "true" do
              questions = category_id |> String.to_integer() |> Categories.get_category!() |> Questions.list_questions()
              acc ++ questions
            else
              acc
            end end)
    end

  end

  def category_checked(categories, category) do
    IO.inspect categories
    cond do
      categories == "all" -> true
      Map.get(categories, Integer.to_string(category.id)) == "true" -> true
      true -> false
    end
  end
end
