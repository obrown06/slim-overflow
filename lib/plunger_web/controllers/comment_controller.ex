defmodule PlungerWeb.CommentController do
  use PlungerWeb, :controller
  plug :authenticate_user when action in [:create]
  alias Plunger.Posts
  alias Plunger.Posts.Comment

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

  def create(conn, attrs) do
    user = conn.assigns.current_user

    question =
      cond do
        (question_id = Map.get(attrs, "question_id")) != nil ->
          Posts.get_question!(question_id)
        (response_id = Map.get(attrs, "response_id")) != nil ->
          response = Posts.get_response!(response_id)
          Posts.get_question!(response.question_id)
        (comment_id = Map.get(attrs, "comment_id")) != nil ->
          comment = Posts.get_comment!(comment_id)
          Posts.get_parent_question!(comment)
        end

    question = Plunger.Repo.preload(question, [:user, :responses, :comments])

    case Posts.create_comment(user, attrs) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = comment_changeset} ->
        response_changeset = question
          |> Ecto.build_assoc(:responses)
          |> Plunger.Posts.Response.changeset()
        render(conn, PlungerWeb.QuestionView, "show.html", question: question,
        comment_changeset: comment_changeset, response_changeset: response_changeset)
    end
  end

  #def upvote(conn, %{"id" => id}, user) do
  #  Plunger.Posts.upvote_comment!(id)
  #end

  #def downvote(conn, %{"id" => id}, user) do
  #  Plunger.Posts.downvote_comment!(id)
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
