defmodule PlungerWeb.SignupController do
  use PlungerWeb, :controller
  alias Plunger.Accounts.User

  def new(conn, params, current_user, _claims) do
    render conn, "new.html", current_user: current_user
  end
end
