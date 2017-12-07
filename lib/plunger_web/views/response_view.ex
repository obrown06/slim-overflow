defmodule PlungerWeb.ResponseView do
  use PlungerWeb, :view
  alias Plunger.Responses
  alias Plunger.Responses.Response
  alias Plunger.Accounts
  alias Plunger.Questions.Question
  alias Plunger.Responses.ResponseVote
  alias Plunger.Repo
  alias Plunger.Comments
  import Ecto.Query, only: [from: 2]

  def associated_user_name(%Response{} = response) do
    user = Responses.associated_user(response)
    Accounts.user_name(user)
  end

  def time_posted(%Response{} = response) do
    Responses.time_posted(response) |> PlungerWeb.ViewHelpers.get_time_posted()
  end

  def vote_count(%Response{} = response) do
    Responses.vote_count(response)
  end

  def description(%Response{} = response) do
    Responses.description(response)
  end

  def list_comments(%Response{} = response) do
    Comments.list_comments(response)
  end

  def user(%Response{} = response) do
    Responses.associated_user(response)
  end

  def user_name(%Response{} = response) do
    user = Responses.associated_user(response)
    Accounts.name(user)
  end

  def id(%Response{} = response) do
    Responses.id(response)
  end

end
