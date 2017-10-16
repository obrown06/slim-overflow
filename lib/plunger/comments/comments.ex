defmodule Plunger.Comments do
  alias Plunger.Comments.Comment
  alias Plunger.Repo
  alias Plunger.Accounts.User
  alias Plunger.Comments.CommentVote
  alias Plunger.Questions.Question
  alias Plunger.Responses
  alias Plunger.Questions
  import Ecto.Query

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment and associates it with its parent comment.
  DO NOT SWITCH THE ORDER; IF YOU DO, ALL COMMENTS WILL BE ASSOCIATED WITH QUESTIONS.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_comment(%User{} = user, %{"comment" => comment_params, "comment_id" => comment_id}) do
    get_comment!(comment_id) |> create_comment(user, comment_params)
  end

  @doc """
  Creates a comment and associates it with its parent response.
  DO NOT SWITCH THE ORDER; IF YOU DO, ALL COMMENTS WILL BE ASSOCIATED WITH QUESTIONS.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_comment(%User{} = user, %{"comment" => comment_params, "response_id" => response_id}) do
    Responses.get_response!(response_id) |> create_comment(user, comment_params)
  end

  @doc """
  Creates a comment and associates it with its parent question.
  DO NOT SWITCH THE ORDER; IF YOU DO, ALL COMMENTS WILL BE ASSOCIATED WITH QUESTIONS.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_comment(%User{} = user, %{"comment" => comment_params, "question_id" => question_id}) do
    Questions.get_question!(question_id) |> create_comment(user, comment_params)
  end

  @doc """
  Creates a comment and associates it with the provided struct (could be question, comment, response).

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  defp create_comment(struct, user, attrs) do
    struct
    |> Ecto.build_assoc(:comments, description: attrs["description"])
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user, :required)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{source: %Comment{}}

  """

  def change_comment(%Comment{} = comment \\ %Comment{}) do
    comment |> Comment.changeset(%{})
  end


  @doc """
  Increments the :votes field in the CommentVote table associated with the given comment_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '1'.

  If the field does exist: increments it for values of '0' and '-1' and does nothing for a value of '1'.

  """

  def upvote_comment!(comment_id, user_id) do
    comment_vote = get_comment_vote(comment_id, user_id)

    cond do
      comment_vote == nil -> create_comment_upvote!(comment_id, user_id)
      comment_vote.votes < 1 ->
        comment_vote
        |> Ecto.Changeset.change(votes: comment_vote.votes + 1)
        |> Repo.update!()
      true -> comment_vote
    end
  end

  @doc """
  Decrements the :votes field in the CommentVote table associated with the given comment_id and user_id.
  If the field doesn't exist, creates and inserts it with a :votes value of '-1'.

  If the field does exist: decrements it for values of '0' and '1' and does nothing for a value of '-1'.

  """

  def downvote_comment!(comment_id, user_id) do
    comment_vote = get_comment_vote(comment_id, user_id)
    cond do
      comment_vote == nil -> create_comment_downvote!(comment_id, user_id)
      comment_vote.votes > -1 ->
        comment_vote
        |> Ecto.Changeset.change(votes: comment_vote.votes - 1)
        |> Repo.update!()
      true -> comment_vote
    end
  end

  @doc """
  Retrieves a CommentVote associated with the given 'comment_id' and 'user_id'.
  If no CommentVote is found, returns nil.

  """

  defp get_comment_vote(comment_id, user_id) do
    Repo.one(from cv in CommentVote, where: cv.comment_id == ^comment_id and cv.user_id == ^user_id)
  end

  @doc """
  Creates a CommentVote struct, associates it with the comment and user corresponding to the given IDs,
  initializes, the :votes field to '1', and inserts.
  """

  defp create_comment_upvote!(comment_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    comment = get_comment!(comment_id)

    changeset =
      user
      |> Ecto.build_assoc(:comment_votes)
      |> CommentVote.changeset()
      |> Ecto.Changeset.change(%{votes: 1})
      |> Ecto.Changeset.put_assoc(:comment, comment, :required)
      |> Repo.insert!()
  end

  @doc """
  Creates a CommentVote struct, associates it with the comment and user corresponding to the given IDs,
  initializes, the :votes field to '-1', and inserts.
  """

  defp create_comment_downvote!(comment_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    comment = get_comment!(comment_id)

    changeset =
      user
      |> Ecto.build_assoc(:comment_votes)
      |> CommentVote.changeset()
      |> Ecto.Changeset.change(%{votes: -1})
      |> Ecto.Changeset.put_assoc(:comment, comment, :required)
      |> Repo.insert!()
  end
end
