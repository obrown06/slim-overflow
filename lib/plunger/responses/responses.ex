defmodule Plunger.Responses do
  alias Plunger.Responses.Response
  alias Plunger.Repo
  alias Plunger.Accounts
  alias Plunger.Accounts.User
  alias Plunger.Questions.Question
  alias Plunger.Responses.ResponseVote
  alias Plunger.Comments
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
  Sets the :is_best field of the given 'response' to true; sets the :is_best field of all
  other responses associated with the given question to false.
  Returns {:ok, response} or an Ecto.Changeset with errors.

  ## Examples

      iex> promote_response(question, response)
      {:ok, %Response{} = response}

  """

  def promote_response(%Question{} = question, %Response{} = response) do
    previous_best_response = best_response(question)

    if previous_best_response != nil do
      demote_response(previous_best_response)
    end

    response
    |> Ecto.Changeset.change(is_best: true)
    |> Repo.update()
  end

  defp demote_response(%Response{} = response \\ nil) do
    response
      |> Ecto.Changeset.change(is_best: false)
      |> Repo.update()
  end

  @doc """
  Increments the :votes field in the ResponseVote table associated with the given response_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '1'.

  If the field does exist: increments it for values of '-1' and '0' and does nothing for a value of '1'.

  Returns true if response_vote was successfully incremented, false otherwise.

  """

  def upvote_response(%Response{} = response, %User{} = user) do
    response_vote = get_response_vote(response, user)
    posting_user = associated_user(response)

    cond do
      Accounts.id(user) == Accounts.id(posting_user) -> false
      response_vote == nil ->
        create_response_upvote!(response, user)
        true
      response_vote.votes < 1 ->
        response_vote
          |> Ecto.Changeset.change(votes: response_vote.votes + 1)
          |> Repo.update!()
        true
      true -> false
    end
  end

  @doc """
  Decrements the :votes field in the ResponseVote table associated with the given response_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '-1'.

  If the field does exist: decrements it for values of '0' and '1' and does nothing for a value of '-1'.

  Returns true if response_vote was successfully decremented, false otherwise.

  """

  def downvote_response(%Response{} = response, %User{} = user) do
    response_vote = get_response_vote(response, user)
    posting_user = associated_user(response)

    cond do
      Accounts.id(user) == Accounts.id(posting_user) -> false
      response_vote == nil ->
        create_response_downvote!(response, user)
        true
      response_vote.votes > -1 ->
        response_vote
          |> Ecto.Changeset.change(votes: response_vote.votes - 1)
          |> Repo.update!()
        true
      true -> false
    end
  end


  #Retrieves a ResponseVote associated with the given 'response_id' and 'user_id'.
  #If no ResponseVote is found, returns nil.

  defp get_response_vote(%Response{} = response, %User{} = user) do
    Repo.one(from rv in ResponseVote, where: rv.response_id == ^id(response) and rv.user_id == ^Accounts.id(user))
  end


  #Creates a ResponseVote struct, associates it with the response and user corresponding to the given IDs,
  #initializes, the :votes field to '1', and inserts.

  defp create_response_upvote!(%Response{} = response, %User{} = user) do
    user
      |> Ecto.build_assoc(:response_votes)
      |> ResponseVote.changeset()
      |> Ecto.Changeset.change(%{votes: 1})
      |> Ecto.Changeset.put_assoc(:response, response, :required)
      |> Repo.insert!()
  end


  #Creates a ResponseVote struct, associates it with the response and user corresponding to the given IDs,
  #initializes, the :votes field to '-1', and inserts.

  defp create_response_downvote!(%Response{} = response, %User{} = user) do
    user
      |> Ecto.build_assoc(:response_votes)
      |> ResponseVote.changeset()
      |> Ecto.Changeset.change(%{votes: -1})
      |> Ecto.Changeset.put_assoc(:response, response, :required)
      |> Repo.insert!()
  end

  # Returns the inserted_at field of the given response

  def time_posted(%Response{} = response) do
    response.inserted_at
  end

  # Returns the user associated with the given response

  def associated_user(%Response{} = response) do
    Accounts.get_user!(response.user_id)
  end

  # Returns the sum of all of the votes for and against a response.

  def vote_count(%Response{} = response) do
    sum = Repo.aggregate((from rv in ResponseVote, where: rv.response_id == ^response.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

  # Returns a response associated with the given question with 'is_best' == true
  # If none found, returns nil

  def best_response(%Question{} = question) do
    Repo.one(from r in Response, where: r.question_id == ^question.id and r.is_best == true )
  end

  # Returns the set of time-ordered responses associated with the given question

  def list_responses(%Question{} = question) do
    (from r in Response, where: r.question_id == ^question.id,
     select: r, order_by: r.inserted_at)
        |> Repo.all
  end

  # Returns the description field of the given response

  def description(%Response{} = response) do
    response.description
  end

  # Returns the set of responses associated with the given user

  def user_responses(%User{} = user) do
    query = (from r in Response,
              where: r.user_id == ^user.id,
              select: r)
      |> Repo.all
  end

  # Returns the id of the given response

  def id(%Response{} = response) do
    response.id
  end

  # Returns the parent question of the given response

  def parent_question(%Response{} = response) do
    response = Repo.preload(response, :question)
    response.question
  end

end
