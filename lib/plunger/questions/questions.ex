defmodule Plunger.Questions do

  alias Plunger.Repo
  alias Plunger.Categories.Category
  alias Plunger.Categories
  alias Plunger.Questions.Question
  import Ecto.Query, warn: false


  @doc """
  Returns the complete list of questions.

  ## Examples

    iex> list_questions()
    [%Question{}, ...]

  """

  def list_questions do
    Repo.all(Question)
  end

  @doc """
  Returns the list of questions associated with a particular category.

  ## Examples

    iex> list_questions()
    [%Question{}, ...]

  """

  def list_questions(%Category{} = category) do
    category =
      category |> Repo.preload(:questions)
    category.questions
  end


  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

    iex> get_question!(123)
    %Question{}

    iex> get_question!(456)
    ** (Ecto.NoResultsError)

  """
  def get_question!(id) do
    Repo.get!(Question, id)
  end

  @doc """
  Gets a single question.

  Returns 'nil' if the Question does not exist.

  ## Examples

    iex> get_question!(123)
    %Question{}

    iex> get_question!(456)
    nil

  """
  #def get_question(id, user) do
  #  Repo.get(list_questions(user), id)
  #end

  #def get_parent_question!(%Response{} = response) do
  #  get_question!(response.question_id)
  #end

  #def get_parent_question!(%Comment{} = comment) do
  #  cond do
  #    comment.question_id != nil ->
  #      get_question!(comment.question_id)
  #    comment.response_id != nil ->
  #      response = Responses.get_response!(comment.response_id)
  #      get_parent_question!(response)
  #    true ->
  #      comment.parent_id
  #      |> Comments.get_comment!()
  #      |> get_parent_question!()
  #    end
  #end

  @doc """
  Creates a question.

  ## Examples

    iex> create_question(%{field: value})
    {:ok, %Question{}}

    iex> create_question(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs, user) do
    changeset =
      user
      |> Ecto.build_assoc(:questions)
      |> Repo.preload(:categories)
      |> Question.changeset(attrs)

    categories = parse_categories(attrs)

    changeset =
      if length(categories) > 0 do
        Ecto.Changeset.put_assoc(changeset, :categories, categories, :required)
      else
        Ecto.Changeset.add_error(changeset, :categories, "you must select a category")
      end

    Repo.insert(changeset)
  end

  defp parse_categories(attrs) do
    attrs
      |> Map.get("categories")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn(category_id) ->
        Categories.get_category!(String.to_integer(category_id))
      end)
  end

  @doc """
  Updates a question.

  ## Examples

    iex> update_question(question, %{field: new_value})
    {:ok, %Question{}}

    iex> update_question(question, %{field: bad_value})
    {:error, %Ecto.Changeset{}}

    """
  def update_question(%Question{} = question, attrs) do
    categories = parse_categories(attrs)

    changeset =
      question
      |> Repo.preload(:categories)
      |> Question.changeset(attrs)

    changeset =
      if length(categories) > 0 do
        Ecto.Changeset.put_assoc(changeset, :categories, categories, :required)
      else
        Ecto.Changeset.add_error(changeset, :categories, "you must select a category")
      end

    Repo.update(changeset)
  end

  @doc """
  Deletes a Question.

  ## Examples

    iex> delete_question(question)
    {:ok, %Question{}}

    iex> delete_question(question)
    {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

    iex> change_question(question)
    %Ecto.Changeset{source: %Question{}}

  """
  def change_question(%Question{} = question \\ %Question{}) do
    question
    |> Repo.preload(:categories)
    |> Question.changeset(%{})
  end

  alias Plunger.Questions.QuestionVote

  @doc """
  Increments the :votes field in the QuestionVote table associated with the given question_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '1'.

  If the field does exist: increments it for values of '-1' and '0' and does nothing for a value of '1'.

  """

  def upvote_question!(question_id, user_id) do
    question_vote = get_question_vote(question_id, user_id)

    cond do
      question_vote == nil -> create_question_upvote!(question_id, user_id)
      question_vote.votes < 1 ->
        question_vote
        |> Ecto.Changeset.change(votes: question_vote.votes + 1)
        |> Repo.update!()
      true -> question_vote
    end
  end

  @doc """
  Decrements the :votes field in the QuestionVote table associated with the given question_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '-1'.

  If the field does exist: decrements it for values of '0' and '1' and does nothing for a value of '-1'.

  """

  def downvote_question!(question_id, user_id) do
    question_vote = get_question_vote(question_id, user_id)
    cond do
      question_vote == nil -> create_question_downvote!(question_id, user_id)
      question_vote.votes > -1 ->
        question_vote
        |> Ecto.Changeset.change(votes: question_vote.votes - 1)
        |> Repo.update!()
      true -> question_vote
    end
  end


  #Retrieves a QuestionVote associated with the given 'question_id' and 'user_id'.
  #If no QuestionVote is found, returns nil.

  defp get_question_vote(question_id, user_id) do
    Repo.one(from qv in QuestionVote, where: qv.question_id == ^question_id and qv.user_id == ^user_id)
  end

  #Creates a QuestionVote struct, associates it with the question and user corresponding to the given IDs,
  #initializes the :votes field to '1', and inserts.

  defp create_question_upvote!(question_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    question = get_question!(question_id)

    user
      |> Ecto.build_assoc(:question_votes)
      |> QuestionVote.changeset()
      |> Ecto.Changeset.change(%{votes: 1})
      |> Ecto.Changeset.put_assoc(:question, question, :required)
      |> Repo.insert!()
  end


  #Creates a QuestionVote struct, associates it with the question and user corresponding to the given IDs,
  #initializes the :votes field to '-1', and inserts.

  defp create_question_downvote!(question_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    question = get_question!(question_id)

    user
      |> Ecto.build_assoc(:question_votes)
      |> QuestionVote.changeset()
      |> Ecto.Changeset.change(%{votes: -1})
      |> Ecto.Changeset.put_assoc(:question, question, :required)
      |> Repo.insert!()
  end

end
