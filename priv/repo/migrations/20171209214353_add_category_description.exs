defmodule Plunger.Repo.Migrations.AddCategoryDescription do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :long_summary, :text
      add :summary, :text
    end
  end
end
