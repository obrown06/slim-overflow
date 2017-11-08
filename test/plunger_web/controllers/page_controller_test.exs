defmodule PlungerWeb.PageControllerTest do
  use PlungerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello Plunger!"
  end
end
