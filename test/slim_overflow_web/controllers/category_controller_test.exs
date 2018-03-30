defmodule SlimOverflowWeb.CategoryControllerTest do
  use SlimOverflowWeb.ConnCase

  alias SlimOverflow.Categories

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:category) do
    {:ok, category} = Categories.create_category(@create_attrs)
    category
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
      user = insert_user(%{email: email, password: "test123"})
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  describe "index" do
    @tag login_as: "test@test.com"
    test "lists all categories", %{conn: conn} do
      conn = get conn, category_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Categories"
    end
  end

  describe "new category" do
    @tag login_as: "test@test.com"
    test "renders form", %{conn: conn} do
      conn = get conn, category_path(conn, :new)
      assert html_response(conn, 200) =~ "New Category"
    end
  end

  describe "create category" do

    @tag login_as: "test@test.com"
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn = post conn, category_path(conn, :create), category: @create_attrs
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == category_path(conn, :show, id)

      conn = refresh_assigns(conn)
      conn = get conn, category_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Category"
    end

    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, category_path(conn, :create), category: @invalid_attrs
      assert html_response(conn, 200) =~ "New Category"
    end
  end

  #describe "edit category" do
  #  setup [:create_category]

  #  test "renders form for editing chosen category", %{conn: conn, category: category} do
  #    conn = get conn, category_path(conn, :edit, category)
  #    assert html_response(conn, 200) =~ "Edit Category"
  #  end
  #end

  #describe "update category" do
  #  setup [:create_category]

  #  test "redirects when data is valid", %{conn: conn, category: category} do
  #    conn = put conn, category_path(conn, :update, category), category: @update_attrs
  #    assert redirected_to(conn) == category_path(conn, :show, category)

  #    conn = get conn, category_path(conn, :show, category)
  #    assert html_response(conn, 200) =~ "some updated name"
  #  end

  #  test "renders errors when data is invalid", %{conn: conn, category: category} do
  #    conn = put conn, category_path(conn, :update, category), category: @invalid_attrs
  #    assert html_response(conn, 200) =~ "Edit Category"
  #  end
  #end

  #describe "delete category" do
  #  setup [:create_category]
#
#    test "deletes chosen category", %{conn: conn, category: category} do
#      conn = delete conn, category_path(conn, :delete, category)
#      assert redirected_to(conn) == category_path(conn, :index)
#      assert_error_sent 404, fn ->
#        get conn, category_path(conn, :show, category)
#      end
#    end
#  end

  defp create_category(_) do
    category = fixture(:category)
    {:ok, category: category}
  end
end
