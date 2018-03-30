defmodule SlimOverflowWeb.UserController do
  use SlimOverflowWeb, :controller
  #plug Guardian.Plug.EnsureAuthenticated when action in [:index, :show, :edit, :update, :delete, :promote]#, handler: __MODULE__
  plug :check_identity when action in [:edit, :edit_email, :edit_password, :update, :update_email, :update_password, :delete]
  plug :load_categories when action in [:show]
  plug :verify_admin when action in [:promote]
  alias SlimOverflow.Accounts
  alias SlimOverflow.Accounts.User

  def index(conn, params) do
    sort = Map.get(params, "sort")

    if sort == nil do
      sort = "reputation"
    end

    users = Accounts.list_users()
    render(conn, "index.html", users: users, sort: sort)
  end

  #def new(conn, _params) do
  #  changeset = Accounts.change_user(%User{})
  #  render(conn, "new.html", changeset: changeset)
  #end

  #def create(conn, %{"user" => user_params}) do
  #  case Accounts.create_user(user_params) do
  #    {:ok, user} ->
  #      conn
  #      |> SlimOverflowWeb.Auth.login(user)
  #      |> put_flash(:info, "User created successfully.")
  #      |> redirect(to: user_path(conn, :show, user))
  #    {:error, %Ecto.Changeset{} = changeset} ->
  #      render(conn, "new.html", changeset: changeset)
  #  end
  #end

  def show(conn, params) do
    id = Map.get(params, "id")
    current_user = Coherence.current_user(conn)
    user = Accounts.get_user!(id)

    Accounts.view_profile!(Accounts.id(current_user), id)

    tab = Map.get(params, "tab")
    sort = Map.get(params, "sort")

    if tab == nil do
      tab = "profile"
    end

    if sort == nil do
      sort = "votes"
    end

    render(conn, "show.html", user: user, tab: tab, sort: sort)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  @doc """
  Create a new confirmation token and resend the email.
  """
  @spec update_email(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def update_email(conn, %{"update" => params}) do
    user = Accounts.get_user!(Coherence.current_user(conn).id)
    cond do
      Coherence.current_user(conn).email != params["current_email"] ->
        conn
        |> put_flash(:error, "The 'Current Email' field must match your own!")
        |> redirect(to: user_path(conn, :edit_email, Coherence.current_user(conn))) #, Coherence.current_user(conn)))
      params["new_email"] != params["confirm_new_email"] ->
        conn
        |> put_flash(:error, "New Email and Confirm New Email fields must match!")
        |> redirect(to: user_path(conn, :edit_email, user)) #, Coherence.current_user(conn)))
      true ->
        case Accounts.update_user_email(user, params) do
          {:ok, updated_user} ->
            user_schema = Coherence.Config.user_schema
            conn
            |> Coherence.ControllerHelpers.send_confirmation(updated_user, user_schema)
            |> put_flash(:info, "Confirmation email sent")
            |> redirect(to: user_path(conn, :show, updated_user))
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "Pick a different email.")
            |> render("edit_email.html", user: user, changeset: changeset)
          end
    end
  end

  def update_categories(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    case Accounts.update_user_categories(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  @doc """
  Create a new confirmation token and resend the email.
  """
  @spec update_password(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def update_password(conn, %{"update" => params}) do
    user = Accounts.get_user!(Coherence.current_user(conn).id)
    cond do
      (not Comeonin.Bcrypt.checkpw(params["current_password"], user.password_hash)) ->
        conn
        |> put_flash(:error, "The 'Current Password' field must match your own!")
        |> redirect(to: user_path(conn, :edit_password, Coherence.current_user(conn))) #, Coherence.current_user(conn)))
      params["new_password"] != params["confirm_new_password"] ->
        conn
        |> put_flash(:error, "New Password and Confirm New Password fields must match!")
        |> redirect(to: user_path(conn, :edit_password, user)) #, Coherence.current_user(conn)))
      true ->
        case Accounts.update_user_password(user, params) do
          {:ok, updated_user} ->
            conn
            |> put_flash(:info, "Password successfully updated")
            |> redirect(to: user_path(conn, :show, updated_user))
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "Pick a different password.")
            |> render("edit_password.html", user: user, changeset: changeset)
          end
    end
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

  def promote(conn, %{"id" => id}) do
    user_to_promote = Accounts.get_user!(id)
    case Accounts.promote_user(user_to_promote) do
      {:ok, promoted_user} ->
        conn
        |> put_flash(:info, "User promoted successfully.")
        |> redirect(to: user_path(conn, :show, promoted_user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", user: user_to_promote, changeset: changeset)
    end
  end

  def check_identity(conn, params) do
    user = Coherence.current_user(conn)
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

  def verify_admin(conn, params) do
    user = Coherence.current_user(conn)
    if user.is_admin do
      conn
    else
      conn
        |> put_flash(:info, "You can't promote users.")
        |> redirect(to: user_path(conn, :index))
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
