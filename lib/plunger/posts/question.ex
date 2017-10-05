defmodule Plunger.Posts.Question do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Posts.Question


  schema "questions" do
    field :body, :string
    field :title, :string
    belongs_to :user, Plunger.Accounts.User, foreign_key: :user_id
    has_many :responses, Plunger.Posts.Response
    many_to_many :categories, Plunger.Posts.Category, join_through: "questions_categories", on_delete: :delete_all, on_replace: :delete
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
