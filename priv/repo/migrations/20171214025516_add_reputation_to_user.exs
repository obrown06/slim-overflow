defmodule SlimOverflow.Repo.Migrations.AddReputationToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reputation, :integer, default: 0
    end
  end
end
