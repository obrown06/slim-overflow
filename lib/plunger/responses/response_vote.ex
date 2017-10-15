defmodule Plunger.Responses.ResponseVote do
  use Ecto.Schema
  alias Plunger.Repo
  import Ecto.Changeset
  alias Plunger.Accounts.User
  alias Plunger.Responses.Response
  alias Plunger.Responses.ResponseVote

  schema "response_votes" do
    field :votes, :integer, default: 0
    belongs_to :response, Response, foreign_key: :response_id
    belongs_to :user, User, foreign_key: :user_id
  end

  def changeset(%ResponseVote{} = response_vote, attrs \\ %{}) do
    response_vote
    |> cast(attrs, [:votes])
    |> validate_required([:votes])
    |> assoc_constraint(:user)
    |> assoc_constraint(:response)
  end
end
