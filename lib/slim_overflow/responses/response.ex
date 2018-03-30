defmodule SlimOverflow.Responses.Response do
  use Ecto.Schema
  import Ecto.Changeset
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Comments.Comment
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Responses.ResponseVote
  alias SlimOverflow.Repo

  @recursion_limit 1000000

  schema "responses" do
    field :description, :string
    field :is_best, :boolean, default: false
    belongs_to :user, User, foreign_key: :user_id
    belongs_to :question, Question, foreign_key: :question_id
    has_many :comments, Comment, on_delete: :delete_all
    has_many :response_votes, ResponseVote, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Response{} = response, attrs \\ %{}) do
    response
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
