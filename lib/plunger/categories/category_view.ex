defmodule Plunger.Categories.CategoryView do
  use Ecto.Schema
  alias Plunger.Repo
  import Ecto.Changeset
  alias Plunger.Accounts.User
  alias Plunger.Categories.Category
  alias Plunger.Categories.CategoryView

  schema "category_views" do
    field :viewed, :boolean, default: true
    belongs_to :category, Category, foreign_key: :category_id
    belongs_to :user, User, foreign_key: :user_id
  end

  def changeset(%CategoryView{} = category_view, attrs \\ %{}) do
    category_view
    |> cast(attrs, [:viewed])
    |> validate_required([:viewed])
    |> assoc_constraint(:user)
    |> assoc_constraint(:category)
  end

end
