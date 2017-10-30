defmodule PlungerWeb.AuthHelpers do
  import Plug.Conn

#  def redirect_back(conn, alternative \\ "/") do
#    path = conn
#    |> get_req_header("referer")
#    |> referrer
#    path || alternative
#  end

def put_user_token(conn, _) do
  if current_user = Guardian.Plug.current_resource(conn) do
    token = Phoenix.Token.sign(conn, "user socket", current_user.id)
    assign(conn, :user_token, token)
  else
    conn
  end
end

#  defp referrer([]), do: nil
#  defp referrer([h|_]), do: h
end
