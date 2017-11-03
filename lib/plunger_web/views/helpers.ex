defmodule PlungerWeb.ViewHelpers do
  def current_user(conn), do: Coherence.current_user(conn)
end
