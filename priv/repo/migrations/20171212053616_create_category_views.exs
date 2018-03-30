defmodule SlimOverflow.Repo.Migrations.CreateCategoryViews do
  use Ecto.Migration

  def change do

    create table(:category_views) do
      add :category_id, references(:categories, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :viewed, :boolean, default: true
    end

    create unique_index(:category_views, [:category_id, :user_id])
  end
end
