defmodule PlungerWeb.UserControllerTest do
  use PlungerWeb.ConnCase

  alias Plunger.Accounts

  @create_attrs %{email: "some email", name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{email: nil, name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  def refresh_assigns(%Plug.Conn{} = conn) do
    saved_assigns = conn.assigns
    conn =
      conn
      |> recycle()
      |> Map.put(:assigns, saved_assigns)
  end

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(%{email: email})
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  describe "index" do
    @tag login_as: "test@test.com"
    test "lists all users", %{conn: conn, user: user} do
      #IO.puts conn.assigns.current_user
      #IO.puts conn.assigns
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  #describe "new user" do
  #  @tag login_as: "nick"
  #  test "renders form", %{conn: conn} do
  #    conn = get conn, user_path(conn, :new)
  #    assert html_response(conn, 200) =~ "New User"
  #  end
  #end

  #describe "create user" do
  #  @tag login_as: "nick"
  #  test "redirects to My Account when data is valid", %{conn: conn} do
  #    conn = post conn, user_path(conn, :create), user: @create_attrs

  #    assert %{id: id} = redirected_params(conn)
  #    assert redirected_to(conn) == user_path(conn, :show, id)

  #    conn = get conn, user_path(conn, :show, id)
  #    assert html_response(conn, 200) =~ "My Account"
  #  end

    #@tag login_as: "nick"
    #test "renders errors when data is invalid", %{conn: conn} do
  #    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    #  assert html_response(conn, 200) =~ "New User"
    #end
  #end

  describe "edit user" do
    #setup [:create_user]

    @tag login_as: "test@test.com"
    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get conn, user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    #setup [:create_user]

    @tag login_as: "test@test.com"
    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update, user), user: @update_attrs
      assert redirected_to(conn) == user_path(conn, :show, user)
      conn = refresh_assigns(conn)
      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "some updated name"
    end

    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  @tag login_as: "test@test.com"
  test "requires user authentication on actions", %{conn: conn, user: user} do
    conn = recycle(conn)
    Enum.each([
      get(conn, user_path(conn, :index)),
      put(conn, user_path(conn, :update, user), user: @update_attrs),
      get(conn, user_path(conn, :edit, user)),
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end

  @tag login_as: "test@test.com"
  test "authorizes actions against access by other users", %{conn: conn, user: user} do

    different_user = insert_user(%{username: "sneaky", email: "sneaky@test.com", name: "sneak"})
    conn = get build_conn(), "/"
    conn = assign(conn, :current_user, different_user)

    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 302)
    assert conn.halted

    conn = put conn, user_path(conn, :update, user), user: @update_attrs
    assert html_response(conn, 302)
    assert conn.halted

  end

  #describe "delete user" do
  #  setup [:create_user]

  #  test "deletes chosen user", %{conn: conn, user: user} do
  #    conn = delete conn, user_path(conn, :delete, user)
  #    assert redirected_to(conn) == user_path(conn, :index)
  #    assert_error_sent 404, fn ->
  #      get conn, user_path(conn, :show, user)
  #    end
  #  end
  #end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
