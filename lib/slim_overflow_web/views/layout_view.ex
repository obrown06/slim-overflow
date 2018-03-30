defmodule SlimOverflowWeb.LayoutView do
  use SlimOverflowWeb, :view
  import SlimOverflowWeb.Coherence.ViewHelpers
  alias SlimOverflow.Accounts
  alias SlimOverflow.Accounts.User

  def show_flash(conn) do
    get_flash(conn) |> flash_msg
  end

  def flash_msg(%{"info" => msg}) do
    ~E"<div><%= msg %></div>"
  end

  def flash_msg(%{"error" => msg}) do
    ~E"<div><%= msg %></div>"
  end

  def flash_msg(_) do
    nil
  end

  def reputation(%User{} = user) do
    Accounts.reputation(user)
  end
end
