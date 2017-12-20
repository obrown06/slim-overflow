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
  alias Plunger.Accounts.ProfileView

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
  Returns all associated responses.

  """

  def responses(%User{} = user) do
    user = user |> Repo.preload(:responses)
    user.responses
  end

  @doc """
  Returns all associated questions.

  """

  def questions(%User{} = user) do
    user = user |> Repo.preload(:questions)
    user.questions
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
    category_reputation = get_category_reputation(user, category)

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

  def get_category_reputation(%User{} = user, %Category{} = category) do
    Repo.one(from cr in CategoryReputation, where: cr.user_id == ^Accounts.id(user) and cr.category_id == ^Categories.id(category))
  end

  defp create_category_reputation!(%User{} = user, %Category{} = category) do
    user
      |> Ecto.build_assoc(:category_reputations)
      |> CategoryReputation.changeset()
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:category, category, :required)
      |> Repo.insert!()
  end

  def reputations(%User{} = user) do
    reputations = Repo.all(from cr in CategoryReputation, where: cr.user_id == ^id(user))
  end

  def reputation_sorted_categories(%User{} = user) do
    user
      |> reputations()
      |> Enum.sort_by(fn(reputation) -> amount(reputation) end)
      |> Enum.map(fn(reputation) ->
          reputation = reputation |> Repo.preload(:category)
          reputation.category end)
  end

  def amount(%CategoryReputation{} = reputation) do
    reputation.amount
  end

  def position(%User{} = user) do
    user.position
  end

  def description(%User{} = user) do
    user.description
  end

  alias Plunger.Accounts.ProfileView

  @doc """
    Creates a profile_view for the given viewing and receiving users if one does not exist already.
  """

  def view_profile!(viewing_user_id, viewed_user_id) do
    if get_profile_view(viewing_user_id, viewed_user_id) == nil do
      create_profile_view!(viewing_user_id, viewed_user_id)
    end
  end

  #Retrieves a ProfileView associated with the given 'viewing_user_id' and 'viewed_user_id'.
  #If no ProfileView is found, returns nil.

  defp get_profile_view(viewing_user_id, viewed_user_id) do
    Repo.one(from pv in ProfileView, where: pv.viewing_user_id == ^viewing_user_id and pv.viewed_user_id == ^viewed_user_id)
  end

  def create_profile_view!(viewing_user_id, viewed_user_id) do
    viewing_user = get_user!(viewing_user_id)
    viewed_user = get_user!(viewed_user_id)

    viewing_user
      |> Ecto.build_assoc(:profiles_viewed)
      |> ProfileView.changeset()
      |> Ecto.Changeset.put_assoc(:viewed_user, viewed_user, :required)
      |> Repo.insert!()
  end


  # Returns the set of category views associated with the given category

  def list_profile_views(%User{} = user) do
    (from pv in ProfileView, where: pv.viewed_user_id == ^user.id) |> Repo.all
  end

end
