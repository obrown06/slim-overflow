defmodule Plunger.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Comments.Comment
  alias Plunger.Accounts.User
  alias Plunger.Questions.Question
  alias Plunger.Responses.Response
  alias Plunger.Comments.CommentVote
  alias Plunger.Repo

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

  @doc """
    Recursively loads parents into struct until it hits nil

    TAKE THIS OUT
    """
  def load_parents(parent) do
    load_parents(parent, @recursion_limit)
  end

  def load_parents(_, limit) when limit < 0, do: raise "Recursion limit reached"

  def load_parents(%Comment{parent: nil} = parent, _), do: parent

  def load_parents(%Comment{parent: %Ecto.Association.NotLoaded{}} = parent, limit) do
    parent = parent |> Repo.preload(:parent)
    Map.update!(parent, :parent, &Comment.load_parents(&1, limit - 1))
  end

  def load_parents(nil, _), do: nil


  @doc """
  Recursively loads children into struct until it hits nil
  """

  def load_children(comment), do: load_children(comment, @recursion_limit)

  def load_children(_, limit) when limit < 0, do: raise "Recursion limit reached"

  #def load_children(%Comment{children: []} = comment, limit), do: comment

  def load_children(%Comment{comments: %Ecto.Association.NotLoaded{}} = comment, limit) do
    comment = comment |> Repo.preload(:comments)
    Map.update!(comment, :comments, fn(list) ->
    Enum.map(list, &Comment.load_children(&1, limit - 1))
    end)
  end

end