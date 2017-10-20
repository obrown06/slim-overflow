defmodule Plunger.Repo.Migrations.AddVotes do
  use Ecto.Migration

  def change do

    create table(:question_votes) do
      add :question_id, references(:questions, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :votes, :integer, default: 0
    end

    create table(:response_votes) do
      add :response_id, references(:responses, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :votes, :integer, default: 0
    end

    create table(:comment_votes) do
      add :comment_id, references(:comments, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      add :votes, :integer, default: 0
    end

    create unique_index(:question_votes, [:question_id, :user_id])
    create unique_index(:response_votes, [:response_id, :user_id])
    create unique_index(:comment_votes, [:comment_id, :user_id])

  end
end
