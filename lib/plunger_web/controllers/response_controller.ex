defmodule PlungerWeb.ResponseController do
  use PlungerWeb, :controller
  plug :authenticate_user when action in [:new, :create, :edit, :update, :delete]
  alias Plunger.Posts
  alias Plunger.Posts.Response

  def index(conn, _params) do
    responses = Posts.list_responses()
    render(conn, "index.html", responses: responses)
  end

  def new(conn, _params) do
    changeset = Posts.change_response(%Response{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"response" => response_params}) do
    case Posts.create_response(response_params) do
      {:ok, response} ->
        conn
        |> put_flash(:info, "Response created successfully.")
        |> redirect(to: response_path(conn, :show, response_params))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    response = Posts.get_response!(id)
    render(conn, "show.html", response: response)
  end

  def edit(conn, %{"id" => id}) do
    response = Posts.get_response!(id)
    changeset = Posts.change_response(response)
    render(conn, "edit.html", response: response, changeset: changeset)
  end

  def update(conn, %{"id" => id, "response" => response_params}) do
    response = Posts.get_response!(id)

    case Posts.update_response(response, response_params) do
      {:ok, response} ->
        conn
        |> put_flash(:info, "Response updated successfully.")
        |> redirect(to: response_path(conn, :show, response))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", response: response, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    response = Posts.get_response!(id)
    {:ok, _response} = Posts.delete_response(response)

    conn
    |> put_flash(:info, "Response deleted successfully.")
    |> redirect(to: response_path(conn, :index))
  end
end
