defmodule Plunger.Accounts.ProfileView do
  use Ecto.Schema
  alias Plunger.Repo
  import Ecto.Changeset
  alias Plunger.Accounts.User
  alias Plunger.Accounts.ProfileView

  schema "profile_views" do
    field :viewed, :boolean, default: true
    belongs_to :viewing_user, User, foreign_key: :viewing_user_id
    belongs_to :viewed_user, User, foreign_key: :viewed_user_id
  end

  def changeset(%ProfileView{} = profile_view, attrs \\ %{}) do
    profile_view
      |> cast(attrs, [:viewed])
      |> validate_required([:viewed])
      |> assoc_constraint(:viewing_user)
      |> assoc_constraint(:viewed_user)
  end

end
