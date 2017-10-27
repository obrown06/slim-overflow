defmodule PlungerWeb.UserController do
  use PlungerWeb, :controller
  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  plug :check_identity when action in [:edit, :update, :delete]
  alias Plunger.Accounts
  alias Plunger.Accounts.User

  def index(conn, _params, user, _claims) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params, user, _claims) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, user, _claims) do
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

  def show(conn, %{"id" => id}, current_user, _claims) do
    user = Accounts.get_user!(id)
    if user == current_user do
      render(conn, "my_account.html", user: user)
    else
      render(conn, "show.html", user: user)
    end
  end

  def edit(conn, %{"id" => id}, user, _claims) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}, user, _claims) do
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

  def promote(conn, %{"id" => id}, user, _claims) do
    promote_user = Accounts.get_user!(id)
    case Accounts.promote(promote_user) do
      {:ok, promoted_user} ->
        conn
        |> put_flash(:info, "User promoted successfully.")
        |> redirect(to: user_path(conn, :show, promoted_user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", user: promote_user, changeset: changeset)
    end
  end

  defp unauthenticated(conn, _params) do
    conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: "/") #NavigationHistory.last_path(conn, 1))
      |> halt()
  end

  def check_identity(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)
    user_id = Map.get(conn.params, "id") |> String.to_integer()
    if user.id == user_id or user.is_admin do
      conn
    else
      conn
      |> put_flash(:error, "You cannot perform this action on this user")
      |> redirect(to: NavigationHistory.last_path(conn, 1))
      |> halt()
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
