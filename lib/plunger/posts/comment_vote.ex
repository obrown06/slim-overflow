defmodule Plunger.Posts.CommentVote do
  use Ecto.Schema
  alias Plunger.Repo
  import Ecto.Changeset
  alias Plunger.Accounts.User
  alias Plunger.Posts.Comment
  alias Plunger.Posts.CommentVote

  schema "comment_votes" do
    field :votes, :integer, default: 0
    belongs_to :comment, Comment, foreign_key: :comment_id
    belongs_to :user, User, foreign_key: :user_id
  end

  def changeset(%CommentVote{} = comment_vote, attrs \\ %{}) do
    comment_vote
    |> cast(attrs, [:votes])
    |> validate_required([:votes])
    |> assoc_constraint(:user)
    |> assoc_constraint(:comment)
  end

end
