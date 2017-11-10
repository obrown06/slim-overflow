defmodule PlungerWeb.QuestionChannelTest do
  use PlungerWeb.ChannelCase
  import Plunger.TestHelpers
  alias PlungerWeb.QuestionChannel

  setup do
    user = insert_user()
    {:ok, _, socket} =
      socket("user_id", %{user_id: user.id})
      |> subscribe_and_join(QuestionChannel, "question:lobby")

    {:ok, socket: socket, user: user}
  end

  test "message broadcasts", %{socket: socket, user: user} do
    name = user.name
    push socket, "new_msg", %{"body" => "hello"}
    assert_broadcast "new_msg", %{body: "hello", user: name}
    #broadcast! socket, "new_msg", %{body: body, user: user.name}
  end

  test "can join a question's chatroom" do
    user = insert_user()
    category = insert_category()
    question = insert_question(user, category)
    {:ok, _, socket} =
      socket("user_id", %{user_id: user.id})
      |> subscribe_and_join(QuestionChannel, "question:{question.id}")
  end

  #test "shout broadcasts to question:lobby", %{socket: socket} do
  #  push socket, "shout", %{"hello" => "all"}
  #  assert_broadcast "shout", %{"hello" => "all"}
  #end

  #test "broadcasts are pushed to the client", %{socket: socket} do
  #  broadcast_from! socket, "broadcast", %{"some" => "data"}
  #  assert_push "broadcast", %{"some" => "data"}
  #end
end
