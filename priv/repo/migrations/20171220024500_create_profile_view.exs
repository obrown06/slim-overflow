defmodule SlimOverflow.Repo.Migrations.CreateProfileView do
  use Ecto.Migration

  def change do
    create table(:profile_views) do
      add :viewing_user_id, references(:users, on_delete: :delete_all)
      add :viewed_user_id, references(:users, on_delete: :delete_all)
      add :viewed, :boolean, default: true
    end

    create unique_index(:profile_views, [:viewing_user_id, :viewed_user_id])
  end
end
