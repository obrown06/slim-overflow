defmodule Plunger.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Categories.Category
  alias Plunger.Categories.CategoryView
  alias Plunger.Accounts.CategoryReputation


  schema "categories" do
    field :name, :string
    field :summary, :string
    field :long_summary, :string
    many_to_many :questions, Plunger.Questions.Question, join_through: "questions_categories", on_delete: :delete_all, on_replace: :delete
    many_to_many :users, Plunger.Accounts.User, join_through: "categories_users", on_delete: :delete_all, on_replace: :delete
    has_many :category_views, CategoryView, on_delete: :delete_all
    has_many :category_reputations, CategoryReputation, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name, :summary, :long_summary])
    |> validate_required([:name, :summary])
    |> unique_constraint(:name)
  end
end
