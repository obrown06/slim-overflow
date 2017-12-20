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
  alias PlungerWeb.CategoryView
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

  def sort_and_partition(categories, %User{} = user, sort_by, num_elems_per_line) do
    categories
      |> sort(sort_by, user)
      |> Enum.chunk_every(3)
  end

  def sort(categories, sort_by, %User{} = user) do
    case sort_by do
      "name" ->
        Enum.sort_by(categories, &Categories.name()/1)
      "votes" ->
        Enum.sort_by(categories,
          fn(category) -> Accounts.get_category_reputation(user, category)
          |> Accounts.amount() end) |> Enum.reverse()
      _ -> raise "This shouldnt happen"
    end
  end

  def sort_and_partition(users, sort_by, num_elems_per_line) do
    users
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

  def reputation_sorted_categories(%User{} = user) do
    Accounts.reputation_sorted_categories(user)
      |> Enum.reverse()
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

  def sorted_answers(%User{} = user, sort_by) do
    Responses.user_responses(user)
      |> Enum.sort_by(fn(response) ->
        case sort_by do
          "votes" -> vote_count(response)
          "newest" -> time_posted(response)
        end
        end)
      |> Enum.reverse()
  end

  def sorted_questions(%User{} = user, sort_by) do
    Questions.user_questions(user)
      |> Enum.sort_by(fn(question) ->
        case sort_by do
          "votes" -> vote_count(question)
          "newest" -> time_posted(question)
        end
        end)
      |> Enum.reverse()
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

  def time_posted(%Response{} = response) do
    Responses.time_posted(response)
  end

  def time_posted(%Question{} = question) do
    Questions.time_posted(question)
  end

  def vote_count(%Question{} = question) do
    Questions.vote_count(question)
  end

  def num_responses(%Question{} = question) do
    Questions.num_responses(question)
  end

  def num_views(%Question{} = question) do
    Questions.list_question_views(question) |> length()
  end

  def age(%User{} = user) do
    age =
      NaiveDateTime.utc_now()
        |> NaiveDateTime.diff(Accounts.time_registered(user))


    years = Kernel.div(age, 31536000)
    age = Kernel.rem(age, 31536000)
    months = Kernel.div(age, 2592000)
    age = Kernel.rem(age, 2592000)
    weeks = Kernel.div(age, 604800)
    age = Kernel.rem(age, 604800)
    days = Kernel.div(age, 86400)

    cond do
      years > 0 ->
        Integer.to_string(years) <> " " <> pluralize(years, "year")
        <> ", " <> Integer.to_string(months) <> " " <> pluralize(months, "month")
      months > 0 ->
        Integer.to_string(months) <> " " <> pluralize(months, "month")
        <> ", " <> Integer.to_string(weeks) <> " " <> pluralize(weeks, "week")
      weeks > 0 ->
        Integer.to_string(weeks) <> " " <> pluralize(weeks, "week")
        <> ", " <> Integer.to_string(days) <> " " <> pluralize(days, "day")
      true -> Integer.to_string(days) <> " " <> pluralize(days, "day")
    end
  end

  def pluralize(amount, string) do
    if amount != 1 do
      string <> "s"
    else
      string
    end
  end

  def num_profile_views(%User{} = user) do
    Accounts.list_profile_views(user) |> length()
  end

  def avatar(%User{} = user) do
    Accounts.avatar(user)
  end

end
