defmodule Plunger.Categories do
  alias Plunger.Repo
  alias Plunger.Categories.Category
  import Ecto.Query


  defp alphabetical(query) do
    from c in query, order_by: c.name
  end

  @doc """
  Assigns the alphabetically sorted list of all categories to :categories in conn.assigns.

  """

  def load_categories(conn, _) do
    query =
      Category
      |> alphabetical()
    categories = Repo.all query
    Plug.Conn.assign(conn, :categories, categories)
  end

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
  Returns a list of all categories whose ids are marked
  as "true" in the given list.

  Input is of the form %{"1" => "true", "2" => "true", "3" => "true", "4" => "true"}

  ## Examples

      iex> list_categories(list)
      [%Category{}, ...]

  """
  def list_categories(boolean_list) do
    boolean_list
    |> Enum.filter(fn(elem) -> elem != "" end)
    |> Enum.reduce([], fn({category_id, value}, acc) ->
        if value == "true" do
          acc ++ [category_id |> String.to_integer() |> get_category!()]
        else
          acc
        end end)
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

  @doc """
  Returns the name field of the given category.

  """

  def name(%Category{} = category) do
    category.name
  end

  @doc """
  Returns the summary field of the given category.

  """

  def summary(%Category{} = category) do
    category.summary
  end

  @doc """
  Returns the long_summary field of the given category.

  """

  def long_summary(%Category{} = category) do
    category.long_summary
  end

  @doc """
  Returns the id field of the given category.

  """

  def id(%Category{} = category) do
    category.id
  end


  alias Plunger.Categories.CategoryView

  @doc """
    Creates a category_view for the given category and user if one does not exist already.
  """

  def view_category!(category_id, user_id) do
    category_view = get_category_view(category_id, user_id)

    case category_view do
      nil -> create_category_view!(category_id, user_id)
      _ -> category_view
    end
  end

  #Retrieves a CategoryView associated with the given 'category_id' and 'user_id'.
  #If no CategoryView is found, returns nil.

  defp get_category_view(category_id, user_id) do
    Repo.one(from cv in CategoryView, where: cv.category_id == ^category_id and cv.user_id == ^user_id)
  end

  def create_category_view!(category_id, user_id) do
    user = Plunger.Accounts.get_user!(user_id)
    category = get_category!(category_id)

    user
      |> Ecto.build_assoc(:category_views)
      |> CategoryView.changeset()
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:category, category, :required)
      |> Repo.insert!()
  end


  # Returns the set of category views associated with the given category

  def list_category_views(%Category{} = category) do
    (from cv in CategoryView, where: cv.category_id == ^category.id) |> Repo.all
  end

  # Returns the set of category views associated with the given category

  def time_posted(%Category{} = category) do
    category.inserted_at
  end

  # Returns the set of category views associated with the given category

  def time_updated(%Category{} = category) do
    category.updated_at
  end

end
