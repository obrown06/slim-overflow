defmodule SlimOverflowWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias SlimOverflowWeb.Router.Helpers

  #def authenticate_user(conn, _opts) do
  #  if Coherence.current_user(conn) do
  #    conn
  #  else
  #    conn
  #    |> put_flash(:error, "You must be logged in to access that page")
  #    |> redirect(to: NavigationHistory.last_path(conn, 1))
  #    |> halt()
  #  end
  #end

  def put_user_token(conn, _) do
    if current_user = Coherence.current_user(conn) do
      #IO.inspect current_user
      user_id_token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      conn = assign(conn, :user_token, user_id_token)
    else
      IO.puts "USER NOT LOGGED IN"
      conn
    end
  end

  #def verify_user(conn, _opts) do
  #  id = Map.get(conn.params, "id") |> String.to_integer()
  #  if Coherence.current_user(conn).id == id do
  #    conn
  #  else
  #    conn
  #    |> put_flash(:error, "You cannot perform this action on this user")
  #    |> redirect(to: NavigationHistory.last_path(conn, 1))
  #    |> halt()
  #  end
  #end

  #def init(opts) do
  #  Keyword.fetch!(opts, :repo)
  #end

  #def call(conn, repo) do
  #  user_id = get_session(conn, :user_id)

  #  cond do
  #    user = conn.assigns[:current_user] ->
  #      conn
  #    user    = user_id && repo.get(SlimOverflow.Accounts.User, user_id) ->
  #      assign(conn, :current_user, user)
  #    true ->
  #      assign(conn, :current_user, nil)
  #    end
  #end

  #def login(conn, user) do
  #  conn
  #  |> assign(:current_user, user)
  #  |> put_session(:user_id, user.id)
  #  |> configure_session(renew: true)
  #end

  #def logout(conn) do
  #  configure_session(conn, drop: true)
  #end

  #def login_by_username_and_pass(conn, username, given_pass, opts) do
  #  repo = Keyword.fetch!(opts, :repo)
  #  user = repo.get_by(SlimOverflow.Accounts.User, username: username)
#
  #  cond do
  #    user && checkpw(given_pass, user.password_hash) ->
  #      {:ok, login(conn, user)}
  #    user ->
  #      {:error, :unauthorized, conn}
  #    true ->
  #      dummy_checkpw()
  #      {:error, :not_found, conn}
  #  end
  #end
end
