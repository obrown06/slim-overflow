defmodule Plunger.Posts.Response do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Posts.Response


  schema "responses" do
    field :description, :string
    belongs_to :user, Plunger.Accounts.User, foreign_key: :user_id
    belongs_to :question, Plunger.Posts.Question, foreign_key: :question_id
    has_many :comments, Plunger.Posts.Comment, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Response{} = response, attrs \\ %{}) do
    response
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
