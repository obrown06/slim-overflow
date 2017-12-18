defmodule Plunger.Accounts.CategoryReputation do
  use Ecto.Schema
  alias Plunger.Repo
  import Ecto.Changeset
  alias Plunger.Accounts.User
  alias Plunger.Categories.Category
  alias Plunger.Accounts.CategoryReputation

  schema "category_reputations" do
    field :amount, :integer, default: 0
    belongs_to :category, Category, foreign_key: :category_id
    belongs_to :user, User, foreign_key: :user_id
  end

  def changeset(%CategoryReputation{} = category_reputation, attrs \\ %{}) do
    category_reputation
      |> cast(attrs, [:amount])
      |> validate_required([:amount])
      |> assoc_constraint(:user)
      |> assoc_constraint(:category)
  end

end
