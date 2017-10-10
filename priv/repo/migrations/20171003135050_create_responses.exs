defmodule Plunger.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :question_id, references(:questions, on_delete: :delete_all)

      timestamps()
    end

    create index(:responses, [:user_id])
    create index(:responses, [:question_id])
  end
end
