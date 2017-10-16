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

  def change_response(%Response{} = response \\ %Response{}) do
    response |> Response.changeset(%{})
  end

  @doc """
  Decrements the :votes field in the ResponseVote table associated with the given response_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '1'.

  If the field does exist: increments it for values of '0' and '-1' and does nothing for a value of '1'.

  """
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

  @doc """
  Decrements the :votes field in the ResponseVote table associated with the given response_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '-1'.

  If the field does exist: decrements it for values of '0' and '1' and does nothing for a value of '-1'.

  """

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

  @doc """
  Retrieves a ResponseVote associated with the given 'response_id' and 'user_id'.
  If no ResponseVote is found, returns nil.

  """

  defp get_response_vote(response_id, user_id) do
    Repo.one(from rv in ResponseVote, where: rv.response_id == ^response_id and rv.user_id == ^user_id)
  end

  @doc """
  Creates a ResponseVote struct, associates it with the response and user corresponding to the given IDs,
  initializes, the :votes field to '1', and inserts.

  """

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

  @doc """
  Creates a ResponseVote struct, associates it with the response and user corresponding to the given IDs,
  initializes, the :votes field to '-1', and inserts. 

  """

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
