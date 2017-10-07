defmodule PlungerWeb.CommentView do
  use PlungerWeb, :view
  alias Plunger.Posts.Comment
  alias Plunger.Accounts


  def get_username(%Comment{} = comment) do
    user = Accounts.get_user!(comment.user_id)
    user.username
  end

  def get_date_time(%Comment{} = comment) do
    comment.inserted_at
  end

end
