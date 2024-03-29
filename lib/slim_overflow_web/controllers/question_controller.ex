defmodule SlimOverflowWeb.QuestionController do
  use SlimOverflowWeb, :controller
  plug :verify_owner when action in [:delete]
  plug :verify_owner_or_admin when action in [:edit, :update]
  plug :load_categories when action in [:new, :create, :edit, :update]
  alias SlimOverflow.Questions
  alias SlimOverflow.Categories
  alias SlimOverflow.Categories.Category
  alias SlimOverflow.Comments
  alias SlimOverflow.Responses
  alias SlimOverflowWeb.UserEmail
  alias SlimOverflow.Accounts

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, Coherence.current_user(conn)])
  end

  def index(conn, params, user) do
    selected_category = Map.get(params, "selected_category")
    sort = Map.get(params, "sort")

    if selected_category == nil do
      selected_category = "all"
    end

    if sort == nil do
      sort = "nil"
    end

    categories =
      case selected_category do
        "all" -> Categories.list_categories()
        _ -> [Categories.get_category!(String.to_integer(selected_category))]
      end

    questions =
      categories
      |> Enum.reduce([], fn(category, acc) -> acc ++ Questions.list_questions(category) end)
      |> Enum.uniq()

    render(conn, "index.html", questions: questions, selected_category: selected_category, sort: sort)
  end

  def new(conn, _params, _user) do
    changeset = Questions.change_question()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"question" => attrs}, user) do
    case Questions.create_question(attrs, user) do
      {:ok, question} ->
        UserEmail.email_interested_users(conn, question)
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def upvote(conn, %{"id" => id}, user) do
    question = Questions.get_question!(id)
    upvote_successful = Questions.upvote_question(question, user)
    posting_user = Questions.associated_user(question)

    if upvote_successful do
      Accounts.add_rep(question, posting_user, "upvote", "posting")
    end

    conn |> json %{ upvote_successful: upvote_successful }
  end

  def downvote(conn, %{"id" => id}, user) do
    question = Questions.get_question!(id)
    downvote_successful = Questions.downvote_question(question, user)
    posting_user = Questions.associated_user(question)

    if downvote_successful do
      Accounts.subtract_rep(question, posting_user, "downvote", "posting")
    end

    conn |> json %{ downvote_successful: downvote_successful }
  end

  def show(conn, %{"id" => id}, user) do
    question = Questions.get_question!(id)
    response_changeset = Responses.change_response()
    comment_changeset = Comments.change_comment()
    Questions.view_question!(id, user.id)

    render(conn, "show.html", question: question, response_changeset:
    response_changeset, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}, user) do
    question = Questions.get_question!(id)
    changeset = Questions.change_question(question)
    render(conn, "edit.html", question: question, changeset: changeset)
  end

  def update(conn, %{"id" => id, "question" => question_params}, user) do
    question = Questions.get_question!(id)
    case Questions.update_question(question, question_params) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: question_path(conn, :show, question))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", question: question, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    question = Questions.get_question!(id)
    case Questions.delete_question(question) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: question_path(conn, :index))
      {:error, _} ->
        raise "Delete Question Failed"
    end
  end

  def verify_owner(conn, params) do
    user = Coherence.current_user(conn)
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

  def verify_owner_or_admin(conn, params) do
    user = Coherence.current_user(conn)
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

end
