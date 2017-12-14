defmodule PlungerWeb.CategoryController do
  use PlungerWeb, :controller
  alias Plunger.Categories
  alias Plunger.Categories.Category
  alias Plunger.Questions

  def index(conn, params) do
    sort = Map.get(params, "sort")

    if sort == nil do
      sort = "questions"
    end

    categories = Categories.list_categories()
    render(conn, "index.html", categories: categories, sort: sort)
  end

  def new(conn, _params) do
    changeset = Categories.change_category(%Category{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"category" => category_params}) do
    case Categories.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: category_path(conn, :show, category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Coherence.current_user(conn)
    category = Categories.get_category!(id)
    Categories.view_category!(id, user.id)
    render(conn, "show.html", category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Categories.get_category!(id)
    changeset = Categories.change_category(category)
    render(conn, "edit.html", category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Categories.get_category!(id)

    case Categories.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: category_path(conn, :show, category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Categories.get_category!(id)
    {:ok, _category} = Categories.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: category_path(conn, :index))
  end
end
