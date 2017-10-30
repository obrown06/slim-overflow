defmodule PlungerWeb.QuestionChannel do
  use Phoenix.Channel

  def join("question:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("question:" <> _private_question_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end
end
