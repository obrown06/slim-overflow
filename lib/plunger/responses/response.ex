defmodule Plunger.Responses.Response do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Responses.Response
  alias Plunger.Questions.Question
  alias Plunger.Comments.Comment
  alias Plunger.Accounts.User
  alias Plunger.Responses.ResponseVote
  alias Plunger.Repo

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

  def load_comments(response), do: load_comments(response, @recursion_limit)

  def load_comments(%Response{comments: %Ecto.Association.NotLoaded{}} = response, limit) do
    response
        |> Repo.preload(:comments) # maybe include a custom query here to preserve some order
        |> Map.update!(:comments, fn(list) ->
            Enum.map(list, fn(c) -> c |> Comment.load_parents(limit - 1) |> Comment.load_children(limit - 1) end)
           end)
  end
end
