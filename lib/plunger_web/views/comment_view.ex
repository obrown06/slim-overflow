defmodule PlungerWeb.CommentView do
  use PlungerWeb, :view
  alias Plunger.Posts.Comment
  alias Plunger.Repo
  alias Plunger.Posts.Question
  alias Plunger.Accounts
  alias Plunger.Posts.Response
  alias PlungerWeb.QuestionView
  import Ecto.Query, only: [from: 2]


  def get_username(%Comment{} = comment) do
    user = Accounts.get_user!(comment.user_id)
    user.username
  end

  def get_date_time(%Comment{} = comment) do
    comment.inserted_at
  end

  def get_comments(%Response{} = response) do
    query = (from c in Comment,
              where: c.response_id == ^response.id,
              select: c)
      |> order_by_time_posted
      |> Repo.all
  end

  def get_comments(%Question{} = question) do
    question = question |> Question.load_comments()
    comments = (from c in Comment,
              where: c.question_id == ^question.id,
              select: c)
      |> order_by_time_posted
      |> Repo.all
  end

  def get_comments(%Comment{} = comment) do
    comment = comment |> Comment.load_children()
    comments = (from c in Comment,
              where: c.parent_id == ^comment.id,
              select: c)
      |> order_by_time_posted
      |> Repo.all
  end

  def order_by_time_posted(query) do
    from t in query,
      order_by: t.inserted_at
  end

end
