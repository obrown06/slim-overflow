defmodule SlimOverflowWeb.QuestionChannel do
  use Phoenix.Channel
  alias SlimOverflow.Questions
  alias SlimOverflow.Accounts

  def join("question:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("question:" <> question_id, _params, socket) do
    question = Questions.get_question!(String.to_integer(question_id))
    {:ok, assign(socket, :question_id, question_id)}
    #{:error, %{reason: "unauthorized"}}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_msg", %{"body" => body}, user, socket) do
    broadcast! socket, "new_msg", %{body: body, user: user.name}
    {:noreply, socket}
  end
end
