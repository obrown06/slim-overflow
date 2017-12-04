defmodule Plunger.Repo.Migrations.MakeCommentFieldText do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      modify :description, :text
    end
  end
end
