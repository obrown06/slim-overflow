defmodule PlungerWeb.ResponseView do
  use PlungerWeb, :view
  alias Plunger.Posts
  alias Plunger.Posts.Response
  alias Plunger.Accounts

  def get_username(%Response{} = response) do
    user = Accounts.get_user!(response.user_id)
    user.username
  end

  def get_date_time(%Response{} = response) do
    response.inserted_at
  end
end
