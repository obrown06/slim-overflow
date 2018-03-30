defmodule SlimOverflow.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Comments.Comment
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Questions.QuestionVote
  alias SlimOverflow.Questions.QuestionView
  alias SlimOverflow.Categories.Category
  alias SlimOverflow.Repo

  @recursion_limit 1000000

  schema "questions" do
    field :body, :string
    field :title, :string
    belongs_to :user, User, foreign_key: :user_id
    has_many :responses, Response, on_delete: :delete_all
    has_many :comments, Comment, on_delete: :delete_all
    many_to_many :categories, Category, join_through: "questions_categories", on_delete: :delete_all, on_replace: :delete
    has_many :question_votes, QuestionVote, on_delete: :delete_all
    has_many :question_views, QuestionView, on_delete: :delete_all
    #has_many :messages, SlimOverflow.Messages.Message, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Question{} = question, attrs \\ %{}) do
    question
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> assoc_constraint(:user)
  end
end
