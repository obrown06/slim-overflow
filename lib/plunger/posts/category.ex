defmodule Plunger.Posts.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Posts.Category


  schema "categories" do
    field :name, :string
    many_to_many :questions, Plunger.Posts.Question, join_through: "questions_categories"

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
