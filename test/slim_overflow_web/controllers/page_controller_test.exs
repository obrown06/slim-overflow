defmodule SlimOverflowWeb.PageControllerTest do
  use SlimOverflowWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello SlimOverflow!"
  end
end
