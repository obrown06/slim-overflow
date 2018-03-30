defmodule SlimOverflow.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false

      timestamps()
    end

    create table(:questions_categories) do
      add :question_id, references(:questions, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create unique_index(:categories, [:name])
    create unique_index(:questions_categories, [:question_id, :category_id])
  end
end
