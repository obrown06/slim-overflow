defmodule Plunger.Repo.Migrations.CreateUserPicture do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar, :string
    end

  end
end
