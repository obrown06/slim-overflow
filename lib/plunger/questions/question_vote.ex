defmodule Plunger.Questions.QuestionVote do
  use Ecto.Schema
  alias Plunger.Repo
  import Ecto.Changeset
  alias Plunger.Accounts.User
  alias Plunger.Questions.Question
  alias Plunger.Questions.QuestionVote

  schema "question_votes" do
    field :votes, :integer, default: 0
    belongs_to :question, Question, foreign_key: :question_id
    belongs_to :user, User, foreign_key: :user_id
  end

  def changeset(%QuestionVote{} = question_vote, attrs \\ %{}) do
    question_vote
    |> cast(attrs, [:votes])
    |> validate_required([:votes])
    |> assoc_constraint(:user)
    |> assoc_constraint(:question)
  end

end
