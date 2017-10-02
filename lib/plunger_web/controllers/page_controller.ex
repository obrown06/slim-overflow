defmodule PlungerWeb.PageController do
  use PlungerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
