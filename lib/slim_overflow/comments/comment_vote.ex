defmodule SlimOverflow.Comments.CommentVote do
  use Ecto.Schema
  alias SlimOverflow.Repo
  import Ecto.Changeset
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Comments.Comment
  alias SlimOverflow.Comments.CommentVote

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
