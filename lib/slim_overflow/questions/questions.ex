defmodule SlimOverflow.Questions do

  alias SlimOverflow.Repo
  alias SlimOverflow.Categories.Category
  alias SlimOverflow.Categories
  alias SlimOverflow.Accounts
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Comments
  alias SlimOverflow.Accounts.User
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

  alias SlimOverflow.Questions.QuestionVote

  @doc """
  Increments the :votes field in the QuestionVote table associated with the given question_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '1'.

  If the field does exist: increments it for values of '-1' and '0' and does nothing for a value of '1'.

  Returns true if question_vote was successfully incremented, false otherwise.

  """

  def upvote_question(%Question{} = question, %User{} = user) do
    question_vote = get_question_vote(question, user)
    posting_user = associated_user(question)

    cond do
      Accounts.id(user) == Accounts.id(posting_user) -> false
      question_vote == nil ->
        create_question_upvote!(question, user)
        true
      question_vote.votes < 1 ->
        question_vote
          |> Ecto.Changeset.change(votes: question_vote.votes + 1)
          |> Repo.update!()
        true
      true -> false
    end
  end

  @doc """
  Decrements the :votes field in the QuestionVote table associated with the given question_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '-1'.

  If the field does exist: decrements it for values of '0' and '1' and does nothing for a value of '-1'.

  Returns true if question_vote was successfully decremented, false otherwise.

  """

  def downvote_question(%Question{} = question, %User{} = user) do
    question_vote = get_question_vote(question, user)
    posting_user = associated_user(question)

    cond do
      Accounts.id(user) == Accounts.id(posting_user) -> false
      question_vote == nil ->
        create_question_downvote!(question, user)
        true
      question_vote.votes > -1 ->
        question_vote
          |> Ecto.Changeset.change(votes: question_vote.votes - 1)
          |> Repo.update!()
        true
      true -> false
    end
  end


  #Retrieves a QuestionVote associated with the given 'question_id' and 'user_id'.
  #If no QuestionVote is found, returns nil.

  defp get_question_vote(%Question{} = question, %User{} = user) do
    Repo.one(from qv in QuestionVote, where: qv.question_id == ^id(question) and qv.user_id == ^Accounts.id(user))
  end

  #Creates a QuestionVote struct, associates it with the question and user corresponding to the given IDs,
  #initializes the :votes field to '1', and inserts.

  defp create_question_upvote!(%Question{} = question, %User{} = user) do
    user
      |> Ecto.build_assoc(:question_votes)
      |> QuestionVote.changeset()
      |> Ecto.Changeset.change(%{votes: 1})
      |> Ecto.Changeset.put_assoc(:question, question, :required)
      |> Repo.insert!()
  end


  #Creates a QuestionVote struct, associates it with the question and user corresponding to the given IDs,
  #initializes the :votes field to '-1', and inserts.

  defp create_question_downvote!(%Question{} = question, %User{} = user) do
    user
      |> Ecto.build_assoc(:question_votes)
      |> QuestionVote.changeset()
      |> Ecto.Changeset.change(%{votes: -1})
      |> Ecto.Changeset.put_assoc(:question, question, :required)
      |> Repo.insert!()
  end

  alias SlimOverflow.Questions.QuestionView

  @doc """
  Increments the :votes field in the QuestionVote table associated with the given question_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '1'.

  If the field does exist: increments it for values of '-1' and '0' and does nothing for a value of '1'.

  """

  def view_question!(question_id, user_id) do
    question_view = get_question_view(question_id, user_id)

    case question_view do
      nil -> create_question_view!(question_id, user_id)
      _ -> question_view
    end
  end

  # Retrieves a QuestionView associated with the given 'question_id' and 'user_id'.
  # If no QuestionView is found, returns nil.

  defp get_question_view(question_id, user_id) do
    Repo.one(from qv in QuestionView, where: qv.question_id == ^question_id and qv.user_id == ^user_id)
  end

  defp create_question_view!(question_id, user_id) do
    user = SlimOverflow.Accounts.get_user!(user_id)
    question = get_question!(question_id)

    user
      |> Ecto.build_assoc(:question_views)
      |> QuestionView.changeset()
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:question, question, :required)
      |> Repo.insert!()
  end

  # Returns a list all categories associated with the given question.

  def get_categories(%Question{} = question) do
    question
    |> Ecto.assoc(:categories)
    |> Repo.all
  end

  # Returns the time the question was posted -- aka the 'inserted_at'
  # field of the given struct

  def time_posted(%Question{} = question) do
    question.inserted_at
  end

  # Returns the 'title' field of the given question struct

  def title(%Question{} = question) do
    question.title
  end

  # Returns the 'body' field of the given question struct

  def body(%Question{} = question) do
    question.body
  end

  # Returns the sum of all of the votes for and against a question.

  def vote_count(%Question{} = question) do
    sum = Repo.aggregate((from qv in QuestionVote, where: qv.question_id == ^question.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

  # Returns the user associated with the given question

  def associated_user(%Question{} = question) do
    Accounts.get_user!(question.user_id)
  end

  # Returns the set of question views associated with the given question

  def list_question_views(%Question{} = question) do
    (from qv in QuestionView, where: qv.question_id == ^question.id) |> Repo.all
  end

  # Returns the set of questions associated with the given user

  def user_questions(%User{} = user) do
    query = (from q in Question,
              where: q.user_id == ^user.id,
              select: q)
      |> Repo.all
  end

  # Returns the number of responses associated with the given question

  def num_responses(%Question{} = question) do
    question |> responses() |> length()
  end

  # Returns the set of responses associated with the given question

  def responses(%Question{} = question) do
    question = Repo.preload(question, :responses)
    question.responses
  end

  # Returns true if question is less than one day old; false otherwise

  def is_under_one_day_old(%Question{} = question) do
    Time.diff(Time.utc_now(),question.inserted_at) < 86400
  end

  # Returns true if question is less than one day old; false otherwise

  def is_under_one_week_old(%Question{} = question) do
    Time.diff(Time.utc_now(),question.inserted_at) < 604800
  end

  def id(%Question{} = question) do
    question.id
  end


  def tagged_with(%Question{} = question, %Category{} = category) do
    question = question |> Repo.preload(:categories)
    Enum.member?(question.categories, category)
  end



end
