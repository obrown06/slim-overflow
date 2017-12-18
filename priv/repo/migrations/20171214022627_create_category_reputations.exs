defmodule Plunger.Repo.Migrations.CreateCategoryReputations do
  use Ecto.Migration

  def change do
    create table(:category_reputations) do
      add :category_id, references(:categories, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :amount, :integer, default: 0
    end

    create unique_index(:category_reputations, [:category_id, :user_id])
  end
end
