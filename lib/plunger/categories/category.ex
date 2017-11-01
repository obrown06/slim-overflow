defmodule Plunger.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Categories.Category


  schema "categories" do
    field :name, :string
    many_to_many :questions, Plunger.Questions.Question, join_through: "questions_categories", on_delete: :delete_all, on_replace: :delete
    many_to_many :users, Plunger.Accounts.User, join_through: "categories_users", on_delete: :delete_all, on_replace: :delete

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
