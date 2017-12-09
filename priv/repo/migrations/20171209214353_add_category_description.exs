defmodule Plunger.Repo.Migrations.AddCategoryDescription do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :description, :string
    end
  end
end
