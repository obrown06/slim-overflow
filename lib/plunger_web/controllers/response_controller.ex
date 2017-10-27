defmodule PlungerWeb.ResponseController do
  use PlungerWeb, :controller
  #plug :authenticate_user when action in [:new, :create, :edit, :update, :delete, :upvote, :downvote]
  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  alias Plunger.Responses
  alias Plunger.Comments
  alias Plunger.Questions

  #def index(conn, _params) do
  #  responses = Posts.list_responses()
  #  render(conn, "index.html", responses: responses)
  #end

  #def new(conn, %{"id" => question_id}) do
  #  user = conn.assigns.current_user
  #  changeset = Posts.change_response(user)
  #  render(conn, "new.html", changeset: changeset, question_id: question_id)
  #end

  #def action(conn, params, user, claims) do
  #  question =
  #    params["question_id"]
  #    |> Questions.get_question!
  #  apply(__MODULE__, action_name(conn),
  #    [conn, conn.params, user, question])
  #end

  def create(conn, params, user, _claims) do
    question = params["question_id"] |> Questions.get_question!
    case Responses.create_response(user, question, params["response"]) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Response created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = response_changeset} ->
        comment_changeset = Comments.change_comment()
        render(conn, PlungerWeb.QuestionView, "show.html", question: question,
        response_changeset: response_changeset, comment_changeset: comment_changeset)
    end
  end

  def promote(conn, params, user, _claims) do
    question = params["question_id"] |> Questions.get_question!
    response = params["id"] |> Responses.get_response!
    case Responses.promote_response(question, response) do
      {:ok, response} ->
        conn
        |> put_flash(:info, "Response promoted successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = response_changeset} ->
        comment_changeset = Comments.change_comment()
        conn
        |> put_flash(:info, "Response not promoted successfully")
        render(conn, PlungerWeb.QuestionView, "show.html", response_changeset: response_changeset,
        comment_changeset: comment_changeset, question: question)
    end
  end

  def upvote(conn, %{"id" => id}, user, _claims) do
    Responses.upvote_response!(id, user.id)
    conn |> redirect(to: NavigationHistory.last_path(conn, 1))
  end

  def downvote(conn, %{"id" => id}, user, _claims) do
    Responses.downvote_response!(id, user.id)
    conn |> redirect(to: NavigationHistory.last_path(conn, 1))
  end

  defp unauthenticated(conn, _params) do
    conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: "/") #NavigationHistory.last_path(conn, 1))
      |> halt()
  end

  #def upvote(conn, %{"id" => id}, user) do
  #  Plunger.Posts.upvote_response!(id)
  #end

  #def downvote(conn, %{"id" => id}, user) do
  #  Plunger.Posts.downvote_response!(id)
  #end

  #def show(conn, %{"id" => id}) do
  #  response = Posts.get_response!(id)
  #  render(conn, "show.html", response: response)
  #end

  #def edit(conn, %{"id" => id}) do
  #  response = Posts.get_response!(id)
  #  changeset = Posts.change_response(response)
  #  render(conn, "edit.html", response: response, changeset: changeset)
  #end

#  def update(conn, %{"id" => id, "response" => response_params}) do
#    response = Posts.get_response!(id)

#    case Posts.update_response(response, response_params) do
#      {:ok, response} ->
#        conn
#        |> put_flash(:info, "Response updated successfully.")
#        |> redirect(to: response_path(conn, :show, response))
#      {:error, %Ecto.Changeset{} = changeset} ->
#        render(conn, "edit.html", response: response, changeset: changeset)
#    end
#  end

  #def delete(conn, %{"id" => id}) do
  #  response = Posts.get_response!(id)
  #  {:ok, _response} = Posts.delete_response(response)

  #  conn
  #  |> put_flash(:info, "Response deleted successfully.")
  #  |> redirect(to: response_path(conn, :index))
  #end
end
