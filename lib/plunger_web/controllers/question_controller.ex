defmodule PlungerWeb.QuestionController do
  use PlungerWeb, :controller
  plug :authenticate_user when action in [:new, :create, :edit, :update, :delete, :upvote, :downvote]
  plug :load_categories when action in [:new, :create, :edit, :update]
  #plug :verify_owner when action in [:edit, :update, :delete]
  alias Plunger.Questions
  alias Plunger.Categories
  alias Plunger.Comments
  alias Plunger.Responses

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, params, _user) do
    question_list =
      case Map.fetch(params, "categories") do
        {:ok, filters} ->
          filters
          #|> Map.get("categories")
          |> Enum.filter(fn(elem) -> elem != "" end)
          |> Enum.reduce([], fn({category_id, value}, acc) ->
            if value == "true" do
              questions = category_id |> String.to_integer() |> Categories.get_category!() |> Questions.list_questions()
              acc ++ questions
            else
              acc
            end end)
        :error -> Questions.list_questions()
      end
    render(conn, "index.html", questions: question_list)
  end

  def new(conn, _params, _user) do
    changeset = Questions.change_question()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"question" => attrs}, user) do
    case Questions.create_question(attrs, user) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def upvote(conn, %{"id" => id}, user) do
    Questions.upvote_question!(id, user.id)
    question = Questions.get_question!(id)
    conn |> redirect(to: NavigationHistory.last_path(conn, 1)) #question_path(conn, :show, question))
  end

  def downvote(conn, %{"id" => id}, user) do
    Questions.downvote_question!(id, user.id)
    question = Questions.get_question!(id)
    conn |> redirect(to: NavigationHistory.last_path(conn, 1)) #question_path(conn, :show, question))
  end

  def show(conn, %{"id" => id}, _user) do
    question = Questions.get_question!(id)
    response_changeset = Responses.change_response()
    comment_changeset = Comments.change_comment()

    render(conn, "show.html", question: question, response_changeset:
    response_changeset, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}, _user) do
    question = Questions.get_question!(id)
    verify_owner(conn, question)
    changeset = Questions.change_question(question)
    render(conn, "edit.html", question: question, changeset: changeset)
  end

  def update(conn, %{"id" => id, "question" => question_params}, _user) do
    question = Questions.get_question!(id)
    verify_owner(conn, question)
    case Questions.update_question(question, question_params) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: question_path(conn, :show, question))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", question: question, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _user) do
    question = Questions.get_question!(id)
    verify_owner(conn, question)
    case Questions.delete_question(question) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: question_path(conn, :index))
      {:error, _} ->
        raise "Delete Question Failed"
    end
  end

  defp verify_owner(conn, question) do
    if conn.assigns.current_user.id == question.user_id do
      conn
    else
      conn
        |> put_flash(:info, "You aren't this question's owner")
        |> redirect(to: question_path(conn, :index))
        |> halt()
    end
  end

end
