defmodule Plunger.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :is_admin, :boolean, default: false
      add :name, :string
      #add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    #create unique_index(:users, [:username])
  end
end
