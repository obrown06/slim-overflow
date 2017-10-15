defmodule Plunger.Responses do
  alias Plunger.Responses.Response
  alias Plunger.Repo
  alias Plunger.Accounts.User
  alias Plunger.Questions.Question
  alias Plunger.Responses.ResponseVote
  import Ecto.Query, warn: false

  @doc """
  Returns the list of responses.

  ## Examples

      iex> list_responses()
      [%Response{}, ...]

  """
  def list_responses do
    Repo.all(Response)
  end

  @doc """
  Gets a single response.

  Raises `Ecto.NoResultsError` if the Response does not exist.

  ## Examples

      iex> get_response!(123)
      %Response{}

      iex> get_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_response!(id), do: Repo.get!(Response, id)

  @doc """
  Creates a response.

  ## Examples

      iex> create_response(%{field: value})
      {:ok, %Response{}}

      iex> create_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_response(%User{} = user, %Question{} = question, attrs \\ %{}) do
    changeset =
      question
      |> Ecto.build_assoc(:responses, description: attrs["description"])
      #|> Repo.preload(:users)
      |> Response.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:user, user, :required)
      |> Repo.insert()
  end

  @doc """
  Updates a response.

  ## Examples

      iex> update_response(response, %{field: new_value})
      {:ok, %Response{}}

      iex> update_response(response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response(%Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Response.

  ## Examples

      iex> delete_response(response)
      {:ok, %Response{}}

      iex> delete_response(response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response(%Response{} = response) do
    Repo.delete(response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response changes.

  ## Examples

      iex> change_response(response)
      %Ecto.Changeset{source: %Response{}}

  """
  def change_response(%User{} = user) do
    user
      |> Ecto.build_assoc(:responses)
      |> Response.changeset(%{})
  end

  def change_response(%Question{} = question) do
    question
      |> Ecto.build_assoc(:responses)
      |> Response.changeset(%{})
  end

  defp get_response_vote(response_id, user_id) do
    Repo.one(from rv in ResponseVote, where: rv.response_id == ^response_id and rv.user_id == ^user_id)
  end

  def upvote_response!(response_id, user_id) do
    response_vote = get_response_vote(response_id, user_id)

    cond do
      response_vote == nil -> create_response_upvote!(response_id, user_id)
      response_vote.votes < 1 ->
        response_vote
        |> Ecto.Changeset.change(votes: response_vote.votes + 1)
        |> Repo.update!()
      true -> response_vote
    end
  end

  def downvote_response!(response_id, user_id) do
    response_vote = get_response_vote(response_id, user_id)
    cond do
      response_vote == nil -> create_response_downvote!(response_id, user_id)
      response_vote.votes > -1 ->
        response_vote
        |> Ecto.Changeset.change(votes: response_vote.votes - 1)
        |> Repo.update!()
      true -> response_vote
    end
  end

  defp create_response_upvote!(response_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    response = get_response!(response_id)

    changeset =
      user
      |> Ecto.build_assoc(:response_votes)
      |> ResponseVote.changeset()
      |> Ecto.Changeset.change(%{votes: 1})
      |> Ecto.Changeset.put_assoc(:response, response, :required)
      |> Repo.insert!()
  end

  defp create_response_downvote!(response_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    response = get_response!(response_id)

    changeset =
      user
      |> Ecto.build_assoc(:response_votes)
      |> ResponseVote.changeset()
      |> Ecto.Changeset.change(%{votes: -1})
      |> Ecto.Changeset.put_assoc(:response, response, :required)
      |> Repo.insert!()
  end

end
