defmodule Plunger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Plunger.Repo

  alias Plunger.Accounts.User
  alias Plunger.Categories
  alias Plunger.Accounts.CategoryReputation
  alias Plunger.Questions
  alias Plunger.Accounts
  alias Plunger.Responses
  alias Plunger.Questions.Question
  alias Plunger.Responses.Response
  alias Plunger.Categories
  alias Plunger.Categories.Category

  @question_rep_boost 5
  @posting_user_upvoted_response_rep_boost 10
  @voting_user_upvoted_response_rep_boost 1
  @posting_user_accepted_response_rep_boost 15
  @question_owner_accepted_response_rep_boost 2

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
  Updates a user's preferred categories.

  ## Examples

      iex> update_user_categories(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_categories(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_user_categories(%User{} = user, %{"categories" => attrs}) do
    categories = parse_categories(attrs)

    changeset =
      user
      |> Repo.preload(:categories)
      |> Ecto.Changeset.change()
      |> put_assoc(:categories, categories, :required)
      |> Repo.update
  end

  @doc """
  Updates a user's name and/or avatar fields.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_user(%User{} = user, attrs) do
    user
      |> User.changeset(attrs)
      |> Repo.update
  end

  @doc """
  Updates a user's password.

  ## Examples

      iex> update_user_password(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_password(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_user_password(%User{} = user, attrs) do
    password_attrs = %{"password" => Map.get(attrs, "new_password")}

    changeset =
      user
      |> User.changeset(password_attrs, :password)
      |> validate_required(:password)
      |> validate_length(:password, min: 4, max: 100)
      |> Repo.update
  end

  @doc """
  Updates a user's email address if the given address is not already taken and
  sets the :confirmed_at field to nil.

  ## Examples

      iex> update_user_email(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_email(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_user_email(%User{} = user, attrs) do
    user
      |> Ecto.Changeset.change(%{:email => attrs["new_email"], :confirmed_at => nil})
      |> unique_constraint(:email)
      |> validate_format(:email, ~r/@/)
      |> Repo.update
  end

  defp parse_categories(attrs) do
    attrs
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

  @doc """
  Promotes a user to admin status by setting the :is_admin field to true.

  ## Examples

      iex> promote_user(user)
      {:ok, %User{}}

      iex> promote_user(user)
      {:error, %Ecto.Changeset{}}

  """

  def promote_user(%User{} = user) do
    user
    |> change(is_admin: true)
    |> Repo.update()
  end

  @doc """
  Returns the name field of the given user struct.

  """

  def name(%User{} = user) do
    user.name
  end

  @doc """
  Returns the boolean is_admin field of the given user struct.

  """

  def is_admin(%User{} = user) do
    user.is_admin
  end

  @doc """
  Returns the avatar field of the given user struct.

  """

  def avatar(%User{} = user) do
    user.avatar
  end

  @doc """
  Returns the avatar field of the given user struct.

  """

  def flagged_categories(%User{} = user) do
    user = user |> Repo.preload(:categories)
    user.categories
  end

  @doc """
  Returns the inserted_at field of the given user struct.

  """

  def time_registered(%User{} = user) do
    user.inserted_at
  end

  @doc """
  Returns the id field of the given user struct.

  """

  def id(%User{} = user) do
    user.id
  end

  @doc """
  Returns the id field of the given user struct.

  """

  def reputation(%User{} = user) do
    user.reputation
  end

  alias Plunger.Accounts.CategoryReputation

  @doc """
  Adds the given amount of rep to the reputation field of the user struct
  and also adds the given amount of rep to the category_reputation structs
  for all of the question's categories.

  """

  def add_rep(%Question{} = question, %User{} = user, "upvote", "posting") do
    update_rep(question, user, @question_rep_boost)
  end

  def add_rep(%Response{} = response, %User{} = user, "upvote", "posting") do
    question = Responses.parent_question(response)
    update_rep(question, user, @posting_user_upvoted_response_rep_boost)
  end

  def add_rep(%Response{} = response, %User{} = user, "upvote", "voting") do
    question = Responses.parent_question(response)
    update_rep(question, user, @voting_user_upvoted_response_rep_boost)
  end

  def add_rep(%Response{} = response, %User{} = user, "accept", "posting") do
    question = Responses.parent_question(response)
    update_rep(question, user, @posting_user_accepted_response_rep_boost)
  end

  def add_rep(%Response{} = response, %User{} = user, "accept", "question_owner") do
    question = Responses.parent_question(response)
    update_rep(question, user, @question_owner_accepted_response_rep_boost)
  end

  def subtract_rep(%Question{} = question, %User{} = user, "downvote", "posting") do
    update_rep(question, user, 0 - @question_rep_boost)
  end

  def subtract_rep(%Response{} = response, %User{} = user, "downvote", "posting") do
    question = Responses.parent_question(response)
    update_rep(question, user, 0 - @posting_user_upvoted_response_rep_boost)
  end

  def subtract_rep(%Response{} = response, %User{} = user, "downvote", "voting") do
    question = Responses.parent_question(response)
    update_rep(question, user, 0 - @voting_user_upvoted_response_rep_boost)
  end

  def subtract_rep(%Response{} = response, %User{} = user, "reject", "posting") do
    question = Responses.parent_question(response)
    update_rep(question, user, 0 - @posting_user_accepted_response_rep_boost)
  end

  def subtract_rep(%Response{} = response, %User{} = user, "reject", "question_owner") do
    question = Responses.parent_question(response)
    update_rep(question, user, 0 - @question_owner_accepted_response_rep_boost)
  end

  def update_rep(%Question{} = question, %User{} = user, delta) do
    user = user |> id() |> Accounts.get_user!()
    IO.puts "delta"
    IO.puts delta
    IO.puts "reputation"
    IO.puts user.reputation
    updated_reputation =
      if user.reputation + delta >= 0 do
        user.reputation + delta
      else
        0
      end

    IO.puts "updated_reputation"
    IO.puts updated_reputation

    user
      |> Ecto.Changeset.change(%{:reputation => updated_reputation})
      |> Repo.update

    question = Repo.preload(question, :categories)

    for category <- question.categories do
      update_rep(category, user, delta)
    end
  end

  def update_rep(%Category{} = category, %User{} = user, delta) do
    user = user |> id() |> Accounts.get_user!()
    category_reputation = get_category_reputation(user.id, category.id)

    if category_reputation == nil do
      category_reputation = create_category_reputation!(user, category)
    end

    updated_reputation =
      if category_reputation.amount + delta >= 0 do
        category_reputation.amount + delta
      else
        0
      end

    category_reputation
      |> Ecto.Changeset.change(%{:amount => updated_reputation})
      |> Repo.update
  end

  defp get_category_reputation(user_id, category_id) do
    Repo.one(from cr in CategoryReputation, where: cr.user_id == ^user_id and cr.category_id == ^category_id)
  end

  defp create_category_reputation!(%User{} = user, %Category{} = category) do
    user
      |> Ecto.build_assoc(:category_reputations)
      |> CategoryReputation.changeset()
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:category, category, :required)
      |> Repo.insert!()
  end


  def reputation_sorted_categories(%User{} = user) do
    reputations = Repo.all(from cr in CategoryReputation, where: cr.user_id == ^id(user))

    reputations
      |> Enum.sort_by(fn(reputation) -> amount(reputation) end)
      |> Enum.map(fn(reputation) ->
          reputation = reputation |> Repo.preload(:category)
          reputation.category end)
  end

  def amount(%CategoryReputation{} = reputation) do
    reputation.amount
  end

end
