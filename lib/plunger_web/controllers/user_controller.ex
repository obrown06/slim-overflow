defmodule PlungerWeb.UserController do
  use PlungerWeb, :controller
  plug :authenticate_user when action in [:index, :show, :delete, :update, :edit]
  plug :verify_user when action in [:edit, :update, :delete]
  alias Plunger.Accounts
  alias Plunger.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> PlungerWeb.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    if user == conn.assigns.current_user do
      render(conn, "my_account.html", user: user)
    else
      render(conn, "show.html", user: user)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  #def delete(conn, %{"id" => id}) do
  #  user = Accounts.get_user!(id)
  #  case Accounts.delete_user!(user) do
  #    {:ok, _user} ->
  #      conn
  #        |> put_flash(:info, "User deleted successfully.")
  #        |> redirect(to: user_path(conn, :index))
  #    {:error, %Ecto.Changeset{} = changeset} ->
  #      render(conn, "index.html", user: user, changeset: changeset)
  #  end
  #end
end
