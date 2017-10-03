defmodule PlungerWeb.ResponseControllerTest do
  use PlungerWeb.ConnCase

  alias Plunger.Posts

  @create_attrs %{description: "some description"}
  @update_attrs %{description: "some updated description"}
  @invalid_attrs %{description: nil}

  def fixture(:response) do
    {:ok, response} = Posts.create_response(@create_attrs)
    response
  end

  describe "index" do
    test "lists all responses", %{conn: conn} do
      conn = get conn, response_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Responses"
    end
  end

  describe "new response" do
    test "renders form", %{conn: conn} do
      conn = get conn, response_path(conn, :new)
      assert html_response(conn, 200) =~ "New Response"
    end
  end

  describe "create response" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, response_path(conn, :create), response: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == response_path(conn, :show, id)

      conn = get conn, response_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Response"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, response_path(conn, :create), response: @invalid_attrs
      assert html_response(conn, 200) =~ "New Response"
    end
  end

  describe "edit response" do
    setup [:create_response]

    test "renders form for editing chosen response", %{conn: conn, response: response} do
      conn = get conn, response_path(conn, :edit, response)
      assert html_response(conn, 200) =~ "Edit Response"
    end
  end

  describe "update response" do
    setup [:create_response]

    test "redirects when data is valid", %{conn: conn, response: response} do
      conn = put conn, response_path(conn, :update, response), response: @update_attrs
      assert redirected_to(conn) == response_path(conn, :show, response)

      conn = get conn, response_path(conn, :show, response)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, response: response} do
      conn = put conn, response_path(conn, :update, response), response: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Response"
    end
  end

  describe "delete response" do
    setup [:create_response]

    test "deletes chosen response", %{conn: conn, response: response} do
      conn = delete conn, response_path(conn, :delete, response)
      assert redirected_to(conn) == response_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, response_path(conn, :show, response)
      end
    end
  end

  defp create_response(_) do
    response = fixture(:response)
    {:ok, response: response}
  end
end
