defmodule Plunger.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false

      timestamps()
    end

    create table(:questions_categories) do
      add :question_id, references(:questions)
      add :category_id, references(:categories)
    end

    create unique_index(:categories, [:name])
    create unique_index(:questions_categories, [:question_id, :category_id])
  end
end
