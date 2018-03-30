defmodule SlimOverflow.Repo.Migrations.AddUserPositionAndDescription do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :position, :string
      add :description, :text
    end
  end
end
