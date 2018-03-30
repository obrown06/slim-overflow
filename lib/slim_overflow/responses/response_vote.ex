defmodule SlimOverflow.Responses.ResponseVote do
  use Ecto.Schema
  alias SlimOverflow.Repo
  import Ecto.Changeset
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Responses.ResponseVote

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
