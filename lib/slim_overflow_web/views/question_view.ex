defmodule SlimOverflowWeb.QuestionView do
  use SlimOverflowWeb, :view
  alias SlimOverflow.Repo
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Accounts
  alias SlimOverflow.Responses
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Categories
  alias SlimOverflow.Categories.Category
  alias SlimOverflow.Comments.Comment
  alias SlimOverflow.Questions.QuestionVote
  alias SlimOverflow.Questions.QuestionView
  alias SlimOverflow.Questions
  alias SlimOverflow.Comments
  import Ecto.Query, only: [from: 2]

  def list_categories(%Question{} = question) do
    Questions.get_categories(question)
      #|> Enum.map(fn(category) -> Categories.name(category) end)
      #|> Enum.join(", ")
  end

  def list_categories() do
    Categories.list_categories()
  end

  def time_posted(%Question{} = question) do
    Questions.time_posted(question) |> SlimOverflowWeb.ViewHelpers.format_time()
  end

  def date_posted(%Question{} = question) do
    Questions.time_posted(question) |> SlimOverflowWeb.ViewHelpers.format_date()
  end

  def title(%Question{} = question) do
    Questions.title(question)
  end

  def body(%Question{} = question) do
    Questions.body(question) |> as_html()
  end

  def truncated_body(%Question{} = question) do
    if String.length(Questions.body(question)) > 165 do
      body = Questions.body(question) |> String.slice(0, 165)
      body <>"..."
    else
      Questions.body(question)
    end
  end

  def vote_count(%Question{} = question) do
    Questions.vote_count(question)
  end

  def user_name(%Question{} = question) do
    user = Questions.associated_user(question)
    Accounts.name(user)
  end

  def user_avatar(%Question{} = question) do
    Questions.associated_user(question)
    |> Accounts.avatar()
  end

  def user(%Question{} = question) do
    Questions.associated_user(question)
  end

  def as_html(text) do
    text
    |> Earmark.as_html!()
    |> raw()
  end

  def num_views(question) do
    Questions.list_question_views(question) |> length()
  end

  def sort(questions, sort_by) do
    case sort_by do
      "nil" -> questions
      "votes" -> Enum.sort_by(questions, &vote_count(&1)) |> Enum.reverse()
      "responses" -> Enum.sort_by(questions, fn(question) ->
        Responses.list_responses(question) |> length() end)
          |> Enum.reverse()
      "date" -> Enum.sort_by(questions, fn(question) ->
        time_posted(question) end)
          |> Enum.reverse()
      "views" -> Enum.sort_by(questions, fn(question) ->
        num_views(question) end)
          |> Enum.reverse()
      _ -> raise "This shouldn't happen"
    end
  end

  def category_selected(category_selects, category) do
    id = Categories.id(category)
    cond do
      category_selects == "all" -> true
      Map.get(category_selects, Integer.to_string(id)) == "true" -> true
      true -> false
    end
  end

  def num_responses(%Question{} = question) do
    Questions.num_responses(question)
  end

  def response_header(%Question{} = question) do
    if num_responses(question) > 1 do
      "Responses"
    else
      "Response"
    end
  end

  def list_responses(%Question{} = question) do
    best_response = Responses.best_response(question)
    responses = Responses.list_responses(question)

    responses = responses |> Enum.filter(fn(response) -> response != best_response end)

    if best_response != nil do
      responses = [best_response | responses]
    end

    responses
  end

  def list_comments(%Question{} = question) do
    Comments.list_comments(question)
  end

end
