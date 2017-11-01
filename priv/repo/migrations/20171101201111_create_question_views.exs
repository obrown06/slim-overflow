defmodule Plunger.Repo.Migrations.CreateQuestionViews do
  use Ecto.Migration

  def change do

    create table(:question_views) do
      add :question_id, references(:questions, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :viewed, :boolean, default: true
    end

    create unique_index(:question_views, [:question_id, :user_id])
  end
end
