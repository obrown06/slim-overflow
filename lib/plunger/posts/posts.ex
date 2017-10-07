defmodule Plunger.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Plunger.Repo
  alias Plunger.Accounts.User
  alias Plunger.Posts
  alias Plunger.Posts.Question
  alias Plunger.Posts.Category

  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  def load_categories(conn, _) do
    query =
      Category
      |> Posts.alphabetical
    categories = Repo.all query
    Plug.Conn.assign(conn, :categories, categories)
  end

  @doc """
  Returns a query containing all the questions scoped to the given user.
  """
  defp user_questions(user) do
    Ecto.assoc(user, :questions)
  end

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  def list_questions(%Category{} = category) do
    category =
      category
      |> Repo.preload(:questions)

    category.questions
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id) do
     Repo.get!(Question, id) |> Repo.preload(:responses)
   end

  @doc """
  Gets a single question.

  Returns 'nil' if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      nil

  """
  def get_question(id, user) do
    Repo.get(user_questions(user), id)
  end

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(user, attrs) do
    changeset =
      user
      |> Ecto.build_assoc(:questions)
      |> Repo.preload(:categories)
      |> Question.changeset(attrs)

    categories = parse_categories(attrs)

    if length(categories) > 0 do
      changeset = Ecto.Changeset.put_assoc(changeset, :categories, categories, :required)
    else
      changeset = Ecto.Changeset.add_error(changeset, :categories, "you must select a category")
    end

    Repo.insert(changeset)
  end

  defp parse_categories(attrs) do
    categories = Map.get(attrs, "categories")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn(category_id) ->
        get_category!(String.to_integer(category_id))
       end)
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    changeset =
      question
      |> Repo.preload(:categories)
      |> Question.changeset(attrs)

    categories = parse_categories(attrs)

    if length(categories) > 0 do
      changeset = Ecto.Changeset.put_assoc(changeset, :categories, categories, :required)
    else
      changeset = Ecto.Changeset.add_error(changeset, :categories, "you must select a category")
    end

    Repo.update(changeset)
  end

  @doc """
  Deletes a Question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{source: %Question{}}

  """
  def change_question(%Question{} = question) do
    question
      |> Repo.preload(:categories)
      |> Question.changeset(%{})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes
  with the user_id field assigned to 'user'.

  """
  def change_question(%User{} = user) do
    user
      |> Ecto.build_assoc(:questions)
      |> change_question()
  end

  alias Plunger.Posts.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias Plunger.Posts.Response

  @doc """
  Returns the list of responses.

  ## Examples

      iex> list_responses()
      [%Response{}, ...]

  """
  def list_responses do
    Repo.all(Response)
  end

  @doc """
  Gets a single response.

  Raises `Ecto.NoResultsError` if the Response does not exist.

  ## Examples

      iex> get_response!(123)
      %Response{}

      iex> get_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_response!(id), do: Repo.get!(Response, id)

  @doc """
  Creates a response.

  ## Examples

      iex> create_response(%{field: value})
      {:ok, %Response{}}

      iex> create_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_response(question_id, %User{} = user, attrs \\ %{}) do
    question = get_question!(question_id) |> Repo.preload([:user, :responses])
    changeset =
      question
      |> Ecto.build_assoc(:responses, description: attrs["description"])
      #|> Repo.preload(:users)
      |> Response.changeset(attrs)
      #|> Ecto.Changeset.put_assoc(:questions, question, :required)
      |> Repo.insert()
  end

  @doc """
  Updates a response.

  ## Examples

      iex> update_response(response, %{field: new_value})
      {:ok, %Response{}}

      iex> update_response(response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response(%Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Response.

  ## Examples

      iex> delete_response(response)
      {:ok, %Response{}}

      iex> delete_response(response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response(%Response{} = response) do
    Repo.delete(response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response changes.

  ## Examples

      iex> change_response(response)
      %Ecto.Changeset{source: %Response{}}

  """
  def change_response(%User{} = user) do
    user
      |> Ecto.build_assoc(:responses)
      |> Response.changeset(%{})
  end

end
