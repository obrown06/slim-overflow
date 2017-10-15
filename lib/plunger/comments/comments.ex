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
  Creates a comment and associates it with a question, response, or comment.

  IMPORTANT: do not flip the order; 'attrs' contains "question_id" and so moving up
  the corresponding 'create_comment' function will cause every comment to be associated
  with its ancestor question and NOT its parent response/comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_comment(%User{} = user, %{"comment" => comment_params, "comment_id" => comment_id}) do
    comment = get_comment!(comment_id)
    |> Ecto.build_assoc(:children, description: comment_params["description"])
    |> Map.put(:parent_id, String.to_integer(comment_id))
    |> Comment.changeset(comment_params)
    |> Ecto.Changeset.put_assoc(:user, user, :required)
    |> Repo.insert()
  end

  def create_comment(%User{} = user, %{"comment" => comment_params, "response_id" => response_id}) do
    response = Responses.get_response!(response_id)
    build_and_insert_comment(response, user, comment_params)
  end

  def create_comment(%User{} = user, %{"comment" => comment_params, "question_id" => question_id}) do
    question = Questions.get_question!(question_id)
    build_and_insert_comment(question, user, comment_params)
  end

  def build_and_insert_comment(struct, user, attrs) do
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
  def change_comment(%Comment{} = comment) do
    Comment.changeset(comment, %{})
  end

  def change_comment(%Question{} = question) do
    question
      |> Ecto.build_assoc(:comments)
      |> Comment.changeset(%{})
  end


  defp get_comment_vote(comment_id, user_id) do
    Repo.one(from cv in CommentVote, where: cv.comment_id == ^comment_id and cv.user_id == ^user_id)
  end

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
