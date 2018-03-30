defmodule SlimOverflow.Repo.Migrations.MakeResponseBodyText do
  use Ecto.Migration

  def change do
    alter table(:responses) do
      modify :description, :text
    end
  end
end
