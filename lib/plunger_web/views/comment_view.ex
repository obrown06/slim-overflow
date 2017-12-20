defmodule PlungerWeb.CommentView do
  use PlungerWeb, :view
  alias Plunger.Comments.Comment
  alias Plunger.Questions.Question
  alias Plunger.Responses.Response
  alias Plunger.Comments.CommentVote
  alias Plunger.Comments
  alias PlungerWeb.QuestionView
  alias Plunger.Accounts
  alias Plunger.Repo
  alias PlungerWeb.UserView
  import Ecto.Query, only: [from: 2]


  def associated_user_name(%Comment{} = comment) do
    user = Comments.associated_user(comment)
    Accounts.name(user)
  end

  def time_posted(%Comment{} = comment) do
    Comments.time_posted(comment) |> PlungerWeb.ViewHelpers.format_time()
  end

  def list_comments(%Comment{} = comment) do
    Comments.list_comments(comment)
  end

  def id(%Comment{} = comment) do
    Comments.id(comment)
  end

  #def get_comments(%Comment{} = comment) do
  #  comments = (from c in Comment,
  #          where: not(is_nil(c.parent_id)) and c.parent_id == ^comment.id,
  #          select: c)
  #    |> order_by_time_posted
  #    |> Repo.all
  #end

  #def get_comments(%Response{} = response) do
  #  comments = (from c in Comment,
  #          where: c.response_id == ^response.id,
  #          select: c)
  #  |> order_by_time_posted
  #  |> Repo.all
  #end

  #def get_comments(%Question{} = question) do
  #  comments = (from c in Comment,
  #          where: c.question_id == ^question.id,
  #          select: c)
  #  |> order_by_time_posted
  #  |> Repo.all
  #end

  #def order_by_time_posted(query) do
  #  from t in query,
  #    order_by: t.inserted_at
  #end

  def vote_count(%Comment{} = comment) do
    Comments.vote_count(comment)
  end

  def list_comments(%Comment{} = comment) do
    Comments.list_comments(comment)
  end

  def user(%Comment{} = comment) do
    Comments.associated_user(comment)
  end

  def user_name(%Comment{} = comment) do
    user = Comments.associated_user(comment)
    Accounts.user_name(user)
  end

end
