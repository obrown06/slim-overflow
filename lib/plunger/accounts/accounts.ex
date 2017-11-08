defmodule Plunger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Plunger.Repo

  alias Plunger.Accounts.User
  alias Plunger.Categories

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_categories(%User{} = user, attrs) do
    categories =
      if Map.get(attrs, "categories") != nil do
        parse_categories(attrs)
      else
        []
      end

    changeset =
      user
      |> Repo.preload(:categories)
      |> User.changeset(attrs)
      |> put_assoc(:categories, categories, :required)
      |> Repo.update
  end

  def update_user(%User{} = user, attrs) do
    user
      |> User.changeset(attrs)
      |> Repo.update
  end

  def update_user_password(%User{} = user, attrs) do
    password_attrs = %{"password" => Map.get(attrs, "new_password")}
    user
      |> User.changeset(password_attrs, :password)
      |> Repo.update
  end

  def update_user_email(%User{} = user, attrs) do
    user
      |> change(%{:email => attrs["new_email"], :confirmed_at => nil})
      |> unique_constraint(:email)
      |> validate_format(:email, ~r/@/)
      |> Repo.update
  end

  defp parse_categories(attrs) do
    attrs
      |> Map.get("categories")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn(category_id) ->
        Categories.get_category!(String.to_integer(category_id))
      end)
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user!(%User{} = user) do
    Repo.delete!(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    user
    |> Repo.preload(:categories)
    |> User.changeset(%{})
  end

  def promote(%User{} = user) do
    user
    |> change(is_admin: true)
    |> Repo.update()
  end
end
