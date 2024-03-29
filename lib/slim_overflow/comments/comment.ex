defmodule SlimOverflow.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias SlimOverflow.Comments.Comment
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Comments.CommentVote
  alias SlimOverflow.Repo

  @recursion_limit 1000000


  schema "comments" do
    field :description, :string
    belongs_to :user, User, foreign_key: :user_id
    belongs_to :question, Question, foreign_key: :question_id
    belongs_to :response, Response, foreign_key: :response_id
    belongs_to :parent, Comment, foreign_key: :parent_id
    has_many :comments, Comment, foreign_key: :parent_id, on_delete: :delete_all
    has_many :comment_votes, CommentVote, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs \\ %{}) do
    comment
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end

end
