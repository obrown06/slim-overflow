defmodule Plunger.Accounts.GuardianToken do
  use Ecto.Schema
  import Ecto.Changeset

  alias Plunger.Repo
  alias Plunger.Accounts.GuardianToken
  alias PlungerWeb.GuardianSerializer
  import Ecto.Query, only: [from: 1, from: 2]

  @primary_key {:jti, :string, []}
  @derive {Phoenix.Param, key: :jti}
  schema "guardian_tokens" do
    field :aud, :string
    field :iss, :string
    field :sub, :string
    field :exp, :integer
    field :jwt, :string
    field :claims, :map

    timestamps()
  end

  def for_user(user) do
    case GuardianSerializer.for_token(user) do
      {:ok, aud} ->
        (from t in GuardianToken, where: t.sub == ^aud)
          |> Repo.all
      _ -> []
    end
  end
end
