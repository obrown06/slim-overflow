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
  alias PlungerWeb.ResponseView
  alias PlungerWeb.QuestionView
  import Ecto.Query, only: [from: 2]

  def posted_questions(%User{} = user) do
    Questions.user_questions(user)
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

  def sort_and_partition(categories, sort_by, num_elems_per_line) do
    categories
      |> sort(sort_by)
      |> Enum.chunk_every(3)
  end

  def is_admin(%User{} = user) do
    Accounts.is_admin(user)
  end

  def sort(users, sort_by) do
    case sort_by do
      "reputation" ->
        Enum.sort_by(users, fn(user) ->
        reputation(user) end) |> Enum.reverse()
      "date" -> Enum.sort_by(users, &Accounts.time_registered()/1, &PlungerWeb.ViewHelpers.naive_date_time_compare()/2) |> Enum.reverse()
      "name" -> Enum.sort_by(users, fn(user) ->
        name(user) end)
      "admins" -> Enum.filter(users, fn(user) -> is_admin(user) end)
      _ -> raise "This shouldn't happen"
    end
  end

  def reputation(%User{} = user) do
    Accounts.reputation(user)
  end

  def top_categories(%User{} = user) do
    user
      |> Accounts.reputation_sorted_categories()
      |> Enum.slice(0, 3)
      |> Enum.reverse()
  end

  def position(%User{} = user) do
    Accounts.position(user)
  end

  def description(%User{} = user) do
    Accounts.description(user)
  end

  def num_category_reputations(%User{} = user) do
    length(Accounts.reputations(user))
  end

  def category_score(%Category{} = category, %User{} = user) do
    Accounts.get_category_reputation(user, category)
      |> Accounts.amount()
  end

  def num_posts_in_category(%Category{} = category, %User{} = user) do
    responses = Accounts.responses(user)
    questions = Accounts.questions(user)

    responses = Enum.filter(responses, fn(response) -> response |> Responses.parent_question() |> Questions.tagged_with(category) end)
    questions = Enum.filter(questions, fn(question) -> question |> Questions.tagged_with(category) end)

    length(responses) + length(questions)

  end

  def vote_sorted_posts(%User{} = user) do
    posts = Questions.user_questions(user) ++ Responses.user_responses(user)
    Enum.sort_by(posts, fn(post) -> vote_count(post) end) |> Enum.reverse()
  end

  def vote_count(%Question{} = question) do
    PlungerWeb.QuestionView.vote_count(question)
  end

  def vote_count(%Response{} = response) do
    PlungerWeb.ResponseView.vote_count(response)
  end

  def is_question(%Question{} = question) do
    true
  end

  def is_question(non_question) do
    false
  end

  def is_or_has_best_response(%Question{} = question) do
    Responses.best_response(question) != nil
  end

  def is_or_has_best_response(%Response{} = response) do
    Responses.is_best(response)
  end

  def title(%Question{} = question) do
    Questions.title(question)
  end

  def parent_question(%Response{} = response) do
    Responses.parent_question(response)
  end

  def date_posted(%Response{} = response) do
    ResponseView.date_posted(response)
  end

  def date_posted(%Question{} = question) do
    QuestionView.date_posted(question)
  end


end
