defmodule PlungerWeb.CommentController do
  use PlungerWeb, :controller
  #plug :authenticate_user when action in [:create, :upvote, :downvote]
  #plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  alias Plunger.Comments
  alias Plunger.Questions
  alias Plunger.Responses

  #def index(conn, _params) do
  #  comments = Posts.list_comments()
  #  render(conn, "index.html", comments: comments)
  #end

  #def new(conn, _params) do
  #  changeset = Posts.change_comment(%Comment{})
  #  render(conn, "new.html", changeset: changeset)
  #end

  #def create(conn, %{"comment" => comment_params}) do
  #  case Posts.create_comment(comment_params) do
  #    {:ok, comment} ->
  #      conn
  #      |> put_flash(:info, "Comment created successfully.")
  #      |> redirect(to: comment_path(conn, :show, comment))
  #    {:error, %Ecto.Changeset{} = changeset} ->
  #      render(conn, "new.html", changeset: changeset)
  #  end
  #end

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
        render(conn, PlungerWeb.QuestionView, "show.html", question: question,
        comment_changeset: comment_changeset, response_changeset: response_changeset)
    end
  end

  def upvote(conn, %{"id" => id}, user, question) do
    upvote_successful = Comments.upvote_comment!(id, user.id)
    #question = Questions.get_question!(id)
    conn |> json %{ upvote_successful: upvote_successful } #redirect(to: NavigationHistory.last_path(conn, 1)) #question_path(conn, :show, question))
  end

  def downvote(conn, %{"id" => id}, user, question) do
    downvote_successful = Comments.downvote_comment!(id, user.id)
    conn |> json %{ downvote_successful: downvote_successful }#question_path(conn, :show, question))
  end

  #defp unauthenticated(conn, _params) do
  #  conn
  #    |> put_flash(:error, "You must be logged in to access that page")
  #    |> redirect(to: "/") #NavigationHistory.last_path(conn, 1))
  #    |> halt()
  #end

  #def show(conn, %{"id" => id}) do
  #  comment = Posts.get_comment!(id)
  #  render(conn, "show.html", comment: comment)
  #end

  #def edit(conn, %{"id" => id}) do
  #  comment = Posts.get_comment!(id)
  #  changeset = Posts.change_comment(comment)
  #  render(conn, "edit.html", comment: comment, changeset: changeset)
  #end

  #def update(conn, %{"id" => id, "comment" => comment_params}) do
  #  comment = Posts.get_comment!(id)

  #  case Posts.update_comment(comment, comment_params) do
  #    {:ok, comment} ->
  #      conn
  #      |> put_flash(:info, "Comment updated successfully.")
  #      |> redirect(to: comment_path(conn, :show, comment))
  #    {:error, %Ecto.Changeset{} = changeset} ->
  #      render(conn, "edit.html", comment: comment, changeset: changeset)
  #  end
  #end

  #def delete(conn, %{"id" => id}) do
  #  comment = Posts.get_comment!(id)
  #  {:ok, _comment} = Posts.delete_comment(comment)

  #  conn
  #  |> put_flash(:info, "Comment deleted successfully.")
  #  |> redirect(to: comment_path(conn, :index))
  #end
end
