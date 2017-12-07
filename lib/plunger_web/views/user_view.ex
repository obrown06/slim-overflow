defmodule PlungerWeb.UserView do
  use PlungerWeb, :view
  alias Plunger.Repo
  alias Plunger.Questions
  alias Plunger.Comments
  alias Plunger.Responses
  alias Plunger.Accounts
  alias Plunger.Questions.Question
  alias Plunger.Responses.Response
  alias Plunger.Comments.Comment
  alias Plunger.Categories
  alias Plunger.Categories.Category
  alias Plunger.Accounts.User
  alias PlungerWeb.CommentView
  import Ecto.Query, only: [from: 2]

  def posted_questions(%User{} = user) do
    Questions.user_questions(user);
  end

  def posted_responses(%User{} = user) do
    Responses.user_responses(user)
  end

  def posted_comments(%User{} = user) do
    Comments.user_comments(user)
  end

  def num_received_comments(%User {} = user) do

    posts = [posted_questions(user), posted_responses(user), posted_comments(user)]
    Kernel.length(posts)

    posts
      |> List.flatten
      |> Enum.reduce(0, fn(post, acc) ->
                          num_posts = post |> Comments.list_comments |> length()
                          acc + num_posts end)

  end

  def name(%User{} = user) do
    Accounts.name(user)
  end

  def flagged_categories(%User{} = user) do
    Accounts.flagged_categories(user)
  end

  def name(%Category{} = category) do
    Categories.name(category)
  end

end
