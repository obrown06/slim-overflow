defmodule SlimOverflow.Repo.Migrations.CreateCategoriesUsers do
  use Ecto.Migration

  def change do
    create table(:categories_users) do
      add :user_id, references(:users)
      add :category_id, references(:categories)
    end

    create unique_index(:categories_users, [:user_id, :category_id])
  end
end
