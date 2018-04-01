defmodule SlimOverflowWeb.CommentController do
  use SlimOverflowWeb, :controller
  #plug :authenticate_user when action in [:create, :upvote, :downvote]
  #plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  alias SlimOverflow.Comments
  alias SlimOverflow.Questions
  alias SlimOverflow.Responses

  def action(conn, _) do
    question =
      conn.params["question_id"]
      |> Questions.get_question!
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, Coherence.current_user(conn), question])
  end

  def create(conn, params, user, question) do
    case Comments.create_comment(user, params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = comment_changeset} ->
        response_changeset = Responses.change_response()
        render(conn, SlimOverflowWeb.QuestionView, "show.html", question: question,
        comment_changeset: comment_changeset, response_changeset: response_changeset)
    end
  end

  def upvote(conn, %{"id" => id}, user, question) do
    upvote_successful = Comments.upvote_comment!(id, user.id)
    #question = Questions.get_question!(id)
    conn |> json %{ upvote_successful: upvote_successful }
  end

  def downvote(conn, %{"id" => id}, user, question) do
    downvote_successful = Comments.downvote_comment!(id, user.id)
    conn |> json %{ downvote_successful: downvote_successful }
  end
end
