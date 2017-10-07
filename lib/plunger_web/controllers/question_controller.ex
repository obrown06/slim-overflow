defmodule PlungerWeb.QuestionController do
  use PlungerWeb, :controller
  plug :authenticate_user when action in [:new, :create, :edit, :update, :delete]
  plug :load_categories when action in [:new, :create, :edit, :update]
  alias Plunger.Posts
  alias Plunger.Posts.Category

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, _user) do
    questions = Posts.list_questions()
    render(conn, "index.html", questions: questions)
  end

  def new(conn, _params, user) do
    changeset = Posts.change_question(user)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"question" => attrs}, user) do
    case Posts.create_question(user, attrs) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    question = Posts.get_question!(id)
    response_changeset = question
      |> Ecto.build_assoc(:responses)
      |> Plunger.Posts.Response.changeset()
    render(conn, "show.html", question: question, response_changeset:
    response_changeset)
  end

  def edit(conn, %{"id" => id}, user) do
    question = Posts.get_question(id, user)

    case question do
      nil ->
        conn
          |> put_flash(:info, "You can't edit this Question")
          |> redirect(to: question_path(conn, :index))
      _ ->
        changeset = Posts.change_question(question)
        render(conn, "edit.html", question: question, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "question" => question_params}, user) do
    question = Posts.get_question(id, user)

    if question == nil do
      conn
        |> put_flash(:info, "You can't update this Question")
        |> redirect(to: question_path(conn, :index))
    else
      case Posts.update_question(question, question_params) do
        {:ok, question} ->
          conn
          |> put_flash(:info, "Question updated successfully.")
          |> redirect(to: question_path(conn, :show, question))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", question: question, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}, user) do
    question = Posts.get_question(id, user)

    case question do
      nil ->
        conn
        |> put_flash(:info, "You can't delete this Question")
        |> redirect(to: question_path(conn, :index))
      _ ->
        {:ok, _question} = Posts.delete_question(question)
        conn
          |> put_flash(:info, "Question deleted successfully.")
          |> redirect(to: question_path(conn, :index))
    end
  end
end
