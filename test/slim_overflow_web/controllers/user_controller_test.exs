defmodule SlimOverflowWeb.UserControllerTest do
  use SlimOverflowWeb.ConnCase

  alias SlimOverflow.Accounts
  alias SlimOverflow.Repo

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

    different_user = insert_user(%{email: "sneaky@test.com", name: "sneak"})
    conn = get build_conn(), "/"
    conn = assign(conn, :current_user, different_user)

    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 302)
    assert conn.halted

    conn = put conn, user_path(conn, :update, user), user: @update_attrs
    assert html_response(conn, 302)
    assert conn.halted

  end

  describe "promote user" do
    @tag login_as: "test@test.com"
    test "admins can promote other users to admins", %{conn: conn, user: user} do
      assert user.is_admin == false

      admin = insert_admin_user()

      conn = assign(conn, :current_user, admin)
      conn = refresh_assigns(conn)
      conn = get conn, user_path(conn, :promote, user)
      #IO.inspect conn
      user = Accounts.get_user!(user.id)
      assert redirected_to(conn) == user_path(conn, :show, user)
      assert user.is_admin == true

    end

    @tag login_as: "test@test.com"
    test "non-admins cannot promote other users to admins", %{conn: conn, user: user} do
      assert user.is_admin == false

      non_admin = insert_user(%{email: "nonadmin@nonadmin.com", name: "nonadmin"})
      conn = assign(conn, :current_user, non_admin)
      conn = refresh_assigns(conn)

      conn = get conn, user_path(conn, :promote, user)
      user = Accounts.get_user!(user.id)
      assert redirected_to(conn) == user_path(conn, :index)
      #assert conn.halted
      assert user.is_admin == false

    end
  end

  describe "edit user password" do
    @tag login_as: "test@test.com"
    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get conn, user_path(conn, :edit_password, user)
      assert html_response(conn, 200) =~ "Confirm new password"
    end
  end

  describe "update user password" do

    @valid_password_params %{"current_password" => "test123", "new_password" => "some updated password", "confirm_new_password" => "some updated password"}
    @invalid_current_password_params %{"current_password" => "invalid current password", "new_password" => "some updated password", "confirm_new_password" => "some updated password"}
    @non_matching_new_password_params %{"current_password" => "test123", "new_password" => "some updated password", "confirm_new_password" => "non-matching password"}
    @invalid_new_password_params %{"current_password" => "test123", "new_password" => "bad", "confirm_new_password" => "bad"}

    @tag login_as: "test@test.com"
    test "updating password updates password", %{conn: conn, user: user} do
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
      conn = post conn, user_path(conn, :update_password, user), update: @valid_password_params
      assert redirected_to(conn) == user_path(conn, :show, user)
      user = Accounts.get_user!(user.id)
      assert Comeonin.Bcrypt.checkpw("some updated password", user.password_hash)
    end

    @tag login_as: "test@test.com"
    test "updating with incorrect current password fails to update", %{conn: conn, user: user} do
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
      conn = post conn, user_path(conn, :update_password, user), update: @invalid_current_password_params
      assert redirected_to(conn) == user_path(conn, :edit_password, user)
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
    end

    @tag login_as: "test@test.com"
    test "updating with non-matching password fields fails to update", %{conn: conn, user: user} do
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
      conn = post conn, user_path(conn, :update_password, user), update: @non_matching_new_password_params
      assert redirected_to(conn) == user_path(conn, :edit_password, user)
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
    end

    @tag login_as: "test@test.com"
    test "updating with invalid password fails to update", %{conn: conn, user: user} do
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
      conn = post conn, user_path(conn, :update_password, user), update: @invalid_new_password_params
      assert html_response(conn, 200) =~ "Pick a different password"
      assert Comeonin.Bcrypt.checkpw("test123", user.password_hash)
    end

  end

  describe "edit user email" do
    @tag login_as: "test@test.com"
    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get conn, user_path(conn, :edit_email, user)
      assert html_response(conn, 200) =~ "Confirm new email"
    end
  end

  describe "update user email" do

    @valid_email_params %{"current_email" => "test@test.com", "new_email" => "new@email.com", "confirm_new_email" => "new@email.com"}
    @invalid_current_email_params %{"current_email" => "invalid@invalid.com", "new_email" => "new@email.com", "confirm_new_email" => "new@email.com"}
    @non_matching_new_email_params %{"current_email" => "test@test.com", "new_email" => "new@email.com", "confirm_new_email" => "non@matching.com"}
    @invalid_new_email_params %{"current_email" => "test@test.com", "new_email" => "invalid", "confirm_new_email" => "invalid"}

    @tag login_as: "test@test.com"
    test "updating email updates email", %{conn: conn, user: user} do
      assert user.email == "test@test.com"
      conn = post conn, user_path(conn, :update_email, user), update: @valid_email_params
      assert redirected_to(conn) == user_path(conn, :show, user)
      user = Accounts.get_user!(user.id)
      assert user.email == "new@email.com"
    end

    @tag login_as: "test@test.com"
    test "updating with incorrect current email fails to update", %{conn: conn, user: user} do
      assert user.email == "test@test.com"
      conn = post conn, user_path(conn, :update_email, user), update: @invalid_current_email_params
      assert redirected_to(conn) == user_path(conn, :edit_email, user)
      assert user.email == "test@test.com"
    end

    @tag login_as: "test@test.com"
    test "updating with non-matching email fields fails to update", %{conn: conn, user: user} do
      assert user.email == "test@test.com"
      conn = post conn, user_path(conn, :update_email, user), update: @non_matching_new_email_params
      assert redirected_to(conn) == user_path(conn, :edit_email, user)
      assert user.email == "test@test.com"
    end

    @tag login_as: "test@test.com"
    test "updating with invalid email fails to update", %{conn: conn, user: user} do
      assert user.email == "test@test.com"
      conn = post conn, user_path(conn, :update_email, user), update: @invalid_new_email_params
      assert html_response(conn, 200) =~ "Pick a different email"
      assert user.email == "test@test.com"
    end

  end

  describe "update user categories" do


    @tag login_as: "test@test.com"
    test "updating with valid categories updates", %{conn: conn, user: user} do
      category_one = insert_category(%{name: "category_one"})
      category_two = insert_category(%{name: "category_two"})
      user = user |> Repo.preload(:categories)
      assert user.categories == []

      valid_category_input = %{"categories" => [Integer.to_string(category_one.id), Integer.to_string(category_two.id)]}
      conn = put conn, user_path(conn, :update_categories, user), user: valid_category_input
      assert redirected_to(conn) == user_path(conn, :show, user)
      user = Accounts.get_user!(user.id) |> Repo.preload(:categories)
      assert user.categories == [category_one, category_two]
    end

    @tag login_as: "test@test.com"
    test "updating with invalid categories fails to update", %{conn: conn, user: user} do
      category_one = insert_category(%{name: "category_one"})
      category_two = insert_category(%{name: "category_two"})
      user = user |> Repo.preload(:categories)
      assert user.categories == []

      invalid_category_input = %{"categories" => [Integer.to_string(category_one.id), "-1"]}
      assert_raise(Ecto.NoResultsError, fn() -> put conn, user_path(conn, :update_categories, user), user: invalid_category_input end)
      user = Accounts.get_user!(user.id) |> Repo.preload(:categories)
      assert user.categories == []
    end
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
