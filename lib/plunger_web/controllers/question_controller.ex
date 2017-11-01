defmodule PlungerWeb.QuestionController do
  use PlungerWeb, :controller
  #plug :authenticate_user when action in [:new, :create, :edit, :update, :delete, :upvote, :downvote]
  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  plug :verify_owner when action in [:delete]
  plug :verify_owner_or_admin when action in [:edit, :update]
  plug :load_categories when action in [:new, :create, :edit, :update]
  alias Plunger.Questions
  alias Plunger.Categories
  alias Plunger.Categories.Category
  alias Plunger.Comments
  alias Plunger.Responses

  #def action(conn, _) do
  #  apply(__MODULE__, action_name(conn),
  #    [conn, conn.params])
  #end

  def index(conn, params, _user, _claims) do
    categories =
      case Map.fetch(params, "categories") do
        {:ok, list} -> list
        :error -> "all"
      end

    render(conn, "index.html", categories: categories, sort: Map.get(params, "sort"))
    #question_list =
    #  case Map.fetch(params, "categories") do
    #    {:ok, category_list} ->
    #      category_list
    #      |> Enum.filter()
    #question_list =
    #  case Map.fetch(params, "categories") do
    #    {:ok, filters} ->
    #      filters
    #      #|> Map.get("categories")
    #      |> Enum.filter(fn(elem) -> elem != "" end)
    #      |> Enum.reduce([], fn({category_id, value}, acc) ->
    #        if value == "true" do
    #          questions = category_id |> String.to_integer() |> Categories.get_category!() |> Questions.list_questions()
    #          acc ++ questions
    #        else
    #          acc
    #        end end)
    #    :error -> Questions.list_questions()
    #  end

    #render(conn, "index.html", questions: question_list, sort: Map.get(params, "sort"))
  end

  def new(conn, _params, _user, _claims) do
    changeset = Questions.change_question()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"question" => attrs}, user, _claims) do
    case Questions.create_question(attrs, user) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def upvote(conn, %{"id" => id}, user, _claims) do
    Questions.upvote_question!(id, user.id)
    question = Questions.get_question!(id)
    conn |> redirect(to: NavigationHistory.last_path(conn, 1)) #question_path(conn, :show, question))
  end

  def downvote(conn, %{"id" => id}, user, _claims) do
    Questions.downvote_question!(id, user.id)
    question = Questions.get_question!(id)
    conn |> redirect(to: NavigationHistory.last_path(conn, 1)) #question_path(conn, :show, question))
  end

  def show(conn, %{"id" => id}, user, _claims) do
    question = Questions.get_question!(id)
    response_changeset = Responses.change_response()
    comment_changeset = Comments.change_comment()
    Questions.view_question!(id, user.id)

    render(conn, "show.html", question: question, response_changeset:
    response_changeset, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}, user, _claims) do
    question = Questions.get_question!(id)
    #verify_owner(conn, question, user)
    changeset = Questions.change_question(question)
    render(conn, "edit.html", question: question, changeset: changeset)
  end

  def update(conn, %{"id" => id, "question" => question_params}, user, _claims) do
    question = Questions.get_question!(id)
    #verify_owner(conn, question, user)
    case Questions.update_question(question, question_params) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: question_path(conn, :show, question))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", question: question, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user, _claims) do
    question = Questions.get_question!(id)
    #verify_owner(conn, question, user)
    case Questions.delete_question(question) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: question_path(conn, :index))
      {:error, _} ->
        raise "Delete Question Failed"
    end
  end

  def verify_owner(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    question = Questions.get_question!(conn.params["id"])
    if user.id == question.user_id do
      conn
    else
      conn
        |> put_flash(:info, "You aren't this question's owner")
        |> redirect(to: question_path(conn, :index))
        |> halt()
    end
  end

  def verify_owner_or_admin(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    question = Questions.get_question!(conn.params["id"])
    if user.id == question.user_id or user.is_admin do
      conn
    else
      conn
        |> put_flash(:info, "You aren't this question's owner")
        |> redirect(to: question_path(conn, :index))
        |> halt()
    end
  end

  def unauthenticated(conn, _params) do
    conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: "/") #NavigationHistory.last_path(conn, 1))
      |> halt()
  end

end
