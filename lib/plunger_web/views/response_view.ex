defmodule PlungerWeb.ResponseView do
  use PlungerWeb, :view
  alias Plunger.Posts
  alias Plunger.Posts.Response
  alias Plunger.Accounts
  alias Plunger.Posts.Question
  alias Plunger.Posts.Response
  alias Plunger.Posts.ResponseVote
  alias Plunger.Repo
  import Ecto.Query, only: [from: 2]

  def get_username(%Response{} = response) do
    user = Accounts.get_user!(response.user_id)
    user.username
  end

  def get_date_time(%Response{} = response) do
    response.inserted_at
  end


  def get_responses(%Question{} = question) do
    query = (from r in Response,
              where: r.question_id == ^question.id,
              select: r)
      |> order_by_time_posted
      |> Repo.all

  end

  def order_by_time_posted(query) do
    from t in query,
      order_by: t.inserted_at
  end

  def get_num_votes(%Response{} = response) do
    Repo.aggregate((from rv in ResponseVote, where: rv.response_id == ^response.id), :sum, :votes)
  end

end
