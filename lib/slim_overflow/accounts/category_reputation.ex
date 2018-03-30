defmodule SlimOverflow.Accounts.CategoryReputation do
  use Ecto.Schema
  alias SlimOverflow.Repo
  import Ecto.Changeset
  alias SlimOverflow.Accounts.User
  alias SlimOverflow.Categories.Category
  alias SlimOverflow.Accounts.CategoryReputation

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
