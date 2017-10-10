defmodule Plunger.Posts.Question do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Posts.Question
  alias Plunger.Repo
  alias Plunger.Posts.Comment

  @recursion_limit 1000000

  schema "questions" do
    field :body, :string
    field :title, :string
    field :votes, :integer, default: 0
    belongs_to :user, Plunger.Accounts.User, foreign_key: :user_id
    has_many :responses, Plunger.Posts.Response, on_delete: :delete_all
    has_many :comments, Plunger.Posts.Comment, on_delete: :delete_all
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

 def load_comments(question), do: load_comments(question, @recursion_limit)

 def load_comments(%Question{comments: %Ecto.Association.NotLoaded{}} = question, limit) do
   question
     |> Repo.preload(:comments)
     |> Map.update!(:comments, fn(list) ->
         Enum.map(list, fn(c) -> c |> Comment.load_parents(limit - 1) |> Comment.load_children(limit-1) end)
        end)
  end
end
