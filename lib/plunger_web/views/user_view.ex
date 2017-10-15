defmodule PlungerWeb.UserView do
  use PlungerWeb, :view
  alias Plunger.Repo
  alias Plunger.Questions.Question
  alias Plunger.Responses.Response
  alias Plunger.Comments.Comment
  alias Plunger.Accounts.User
  alias PlungerWeb.CommentView
  import Ecto.Query, only: [from: 2]

  def posted_questions(%User{} = user) do
    query = (from q in Question,
              where: q.user_id == ^user.id,
              select: q)
      |> Repo.all
  end

  def posted_responses(%User{} = user) do
    query = (from r in Response,
              where: r.user_id == ^user.id,
              select: r)
      |> Repo.all
  end

  def posted_comments(%User{} = user) do
    query = (from c in Comment,
              where: c.user_id == ^user.id,
              select: c)
      |> Repo.all
  end

  def num_received_comments(%User {} = user) do

    posts = [posted_questions(user), posted_responses(user), posted_comments(user)]

    posts
      |> List.flatten
      |> Enum.reduce(0, fn(post, acc) ->
                        if post == %Comment{} do
                          post = post |> Comment.load_children() |> Comment.load_parents()
                        end
                        num_posts = post |> CommentView.get_comments |> length()
                        acc + num_posts end)
  end

end
