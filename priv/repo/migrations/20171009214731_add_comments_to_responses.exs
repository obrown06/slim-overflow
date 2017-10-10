defmodule Plunger.Repo.Migrations.AddCommentsToResponses do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :response_id, references(:responses, on_delete: :delete_all)
    end

    create index(:comments, [:response_id])
  end
end
