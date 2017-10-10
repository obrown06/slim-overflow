defmodule Plunger.Repo.Migrations.AddVotes do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :votes, :integer, default: 0
    end
    alter table(:responses) do
        add :votes, :integer, default: 0
    end
    alter table(:comments) do
        add :votes, :integer, default: 0
    end
  end
end
