defmodule SlimOverflow.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :question_id, references(:questions, on_delete: :delete_all)

      timestamps()
    end

    create index(:comments, [:user_id])
    create index(:comments, [:question_id])
  end
end
