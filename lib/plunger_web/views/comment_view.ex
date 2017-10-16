defmodule PlungerWeb.CommentView do
  use PlungerWeb, :view
  alias Plunger.Comments.Comment
  alias Plunger.Questions.Question
  alias Plunger.Responses.Response
  alias Plunger.Comments.CommentVote
  alias PlungerWeb.QuestionView
  alias Plunger.Accounts
  alias Plunger.Repo
  import Ecto.Query, only: [from: 2]


  def get_username(%Comment{} = comment) do
    user = Accounts.get_user!(comment.user_id)
    user.username
  end

  def get_date_time(%Comment{} = comment) do
    comment.inserted_at
  end

  def get_nested_comments(%Response{} = response) do
    response
      |> Response.load_comments()
      |> Map.get(:comments)
      |> Enum.sort_by(&get_date_time(&1))
      |> Enum.reduce([], fn(comment, acc) -> [comment] ++ get_nested_comments(comment) ++ acc end)
  end

  def get_nested_comments(%Question{} = question) do
    question
      |> Question.load_comments()
      |> Map.get(:comments)
      |> Enum.sort_by(&get_date_time(&1))
      |> Enum.reduce([], fn(comment, acc) -> [comment] ++ get_nested_comments(comment) ++ acc end)
  end

  def get_nested_comments(%Comment{} = comment) do
    comment_list = comment |> Map.get(:comments)
    |> Enum.sort_by(&get_date_time(&1))
    |> Enum.reduce([], fn(comment, acc) -> [comment] ++ get_nested_comments(comment) ++ acc end)
  end

  def get_comments(%Comment{} = comment) do
    comments = (from c in Comment,
            where: not(is_nil(c.parent_id)) and c.parent_id == ^comment.id,
            select: c)
      |> order_by_time_posted
      |> Repo.all
  end

  def get_comments(%Response{} = response) do
    comments = (from c in Comment,
            where: c.response_id == ^response.id,
            select: c)
    |> order_by_time_posted
    |> Repo.all
  end

  def get_comments(%Question{} = question) do
    comments = (from c in Comment,
            where: c.question_id == ^question.id,
            select: c)
    |> order_by_time_posted
    |> Repo.all
  end

  def order_by_time_posted(query) do
    from t in query,
      order_by: t.inserted_at
  end

  def get_num_votes(%Comment{} = comment) do
    sum = Repo.aggregate((from cv in CommentVote, where: cv.comment_id == ^comment.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

end
