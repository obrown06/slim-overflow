defmodule SlimOverflowWeb.ResponseView do
  use SlimOverflowWeb, :view
  alias SlimOverflow.Responses
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Accounts
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Responses.ResponseVote
  alias SlimOverflow.Repo
  alias SlimOverflow.Comments
  import Ecto.Query, only: [from: 2]

  def associated_user_name(%Response{} = response) do
    user = Responses.associated_user(response)
    Accounts.user_name(user)
  end

  def time_posted(%Response{} = response) do
    Responses.time_posted(response) |> SlimOverflowWeb.ViewHelpers.format_time()
  end

  def date_posted(%Response{} = response) do
    Responses.time_posted(response) |> SlimOverflowWeb.ViewHelpers.format_date()
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
