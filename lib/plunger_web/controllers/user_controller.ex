defmodule PlungerWeb.UserController do
  use PlungerWeb, :controller
  #plug Guardian.Plug.EnsureAuthenticated when action in [:index, :show, :edit, :update, :delete, :promote]#, handler: __MODULE__
  plug :check_identity when action in [:edit, :update, :delete]
  plug :load_categories when action in [:show]
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
    current_user = Coherence.current_user(conn)
    user = Accounts.get_user!(id)
    if user.id == current_user.id do
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

  def edit_email(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    #changeset = Accounts.change_user(user)
    render(conn, "edit_email.html", user: user)
  end

  @doc """
  Create a new confirmation token and resend the email.
  """
  @spec create(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def update_email(conn, %{"update" => params}) do
    user = Coherence.Schemas.get_by_user email: params["current_email"]
    cond do
      user == nil or Coherence.current_user(conn).id != user.id ->
        conn
        |> put_flash(:info, "The 'Current Email' field must match your own!")
        |> redirect(to: user_path(conn, :edit_email, Coherence.current_user(conn))) #, Coherence.current_user(conn)))
      params["new_email"] != params["confirm_new_email"] ->
        conn
        |> put_flash(:info, "New Email and Confirm New Email fields must match!")
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
            render(conn, "edit_email.html", user: user, changeset: changeset)
            #conn
            #|> put_flash(:error, "Errors; see below")
            #|> redirect(to: user_path(conn, :edit_email, user)) #, Coherence.current_user(conn)))
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

  #def update_email(conn, params) do
  #  user = Accounts.get_user!(params["id"])
  #  case Accounts.update_user_email(user, params["user"]) do
  #    {:ok, user} ->
  #      conn
  #      |> put_flash(:info, "Email updated; confirm it to reactivate your account.")
  #      |> redirect(to: confirmation_path(conn, :create, user, params))
  #    {:error, %Ecto.Changeset{} = changeset} ->
  #      render(conn, "edit_email.html", user: user, changeset: changeset)
  #  end
  #end

  def promote(conn, %{"id" => id}) do
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

  #defp unauthenticated(conn, _params) do
  #  conn
  #    |> put_flash(:error, "You must be logged in to access that page")
  #    |> redirect(to: "/") #NavigationHistory.last_path(conn, 1))
  #    |> halt()
  #end

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

  def confirm(conn, %{"id" => id}) do
    case Accounts.get_user!(id) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: user_path(conn, :index))
      user ->
        case Controller.confirm! user do
          {:error, changeset}  ->
            conn
            |> put_flash(:error, format_errors(changeset))
          _ ->
            put_flash(conn, :info, "User confirmed!")
        end
        |> redirect(to: user_path(conn, :show, user.id))
      end
  end

  def lock(conn, %{"id" => id}) do
    locked_at = DateTime.utc_now
    |> Timex.shift(years: 10)

    case Accounts.get_user!(id) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: user_path(conn, :index))
      user ->
        case Controller.lock! user, locked_at do
          {:error, changeset}  ->
            conn
            |> put_flash(:error, format_errors(changeset))
          _ ->
            put_flash(conn, :info, "User locked!")
        end
        |> redirect(to: user_path(conn, :show, user.id))
      end
  end

  def unlock(conn, %{"id" => id}) do
    case Accounts.get_user!(id) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: user_path(conn, :index))
      user ->
        case Controller.unlock! user do
          {:error, changeset}  ->
            conn
            |> put_flash(:error, format_errors(changeset))
          _ ->
            put_flash(conn, :info, "User unlocked!")
          end
          |> redirect(to: user_path(conn, :show, user.id))
      end
  end

  defp format_errors(changeset) do
    for error <- changeset.errors do
      case error do
        {:locked_at, {err, _}} -> err
        {_field, {err, _}} when is_binary(err) or is_atom(err) ->
          "#{err}"
        other -> inspect other
      end
    end
    |> Enum.join("<br \>\n")
  end

end
