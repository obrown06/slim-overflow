defmodule PlungerWeb.ResponseView do
  use PlungerWeb, :view
  alias Plunger.Responses
  alias Plunger.Responses.Response
  alias Plunger.Accounts
  alias Plunger.Questions.Question
  alias Plunger.Responses.ResponseVote
  alias Plunger.Repo
  import Ecto.Query, only: [from: 2]

  def get_username(%Response{} = response) do
    user = Accounts.get_user!(response.user_id)
    user.username
  end

  def get_name(%Response{} = response) do
    user = Accounts.get_user!(response.user_id)
    user.name
  end

  def get_date_time(%Response{} = response) do
    response.inserted_at
  end


  def get_responses(%Question{} = question) do
    responses = (from r in Response,
              where: r.question_id == ^question.id,
              select: r)
      |> order_by_time_posted
      |> Repo.all

    question = question |> Repo.preload(:responses)
    best = Enum.filter(question.responses, fn(r) -> r.is_best == true end)

    if [best] != [] do
      rest = responses |> Enum.filter(fn(response) -> [response] != best end)
      best ++ rest
    else
      responses
    end
  end

  def order_by_time_posted(query) do
    from t in query,
      order_by: t.inserted_at
  end

  def get_num_votes(%Response{} = response) do
    sum = Repo.aggregate((from rv in ResponseVote, where: rv.response_id == ^response.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

end
