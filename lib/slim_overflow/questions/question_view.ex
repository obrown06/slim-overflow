defmodule SlimOverflow.Questions.QuestionView do
  use Ecto.Schema
  alias SlimOverflow.Repo
  import Ecto.Changeset
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Questions.QuestionView

  schema "question_views" do
    field :viewed, :boolean, default: true
    belongs_to :question, Question, foreign_key: :question_id
    belongs_to :user, User, foreign_key: :user_id
  end

  def changeset(%QuestionView{} = question_view, attrs \\ %{}) do
    question_view
    |> cast(attrs, [:viewed])
    |> validate_required([:viewed])
    |> assoc_constraint(:user)
    |> assoc_constraint(:question)
  end

end
