defmodule SlimOverflowWeb.ResponseController do
  use SlimOverflowWeb, :controller
  alias SlimOverflow.Responses
  alias SlimOverflow.Comments
  alias SlimOverflow.Questions
  alias SlimOverflow.Accounts

  def create(conn, %{"response" => response_params}) do
    user = Coherence.current_user(conn)
    question = conn.params["question_id"] |> Questions.get_question!()
    case Responses.create_response(user, question, response_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Response created successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = response_changeset} ->
        comment_changeset = Comments.change_comment()
        render(conn, SlimOverflowWeb.QuestionView, "show.html", question: question,
        response_changeset: response_changeset, comment_changeset: comment_changeset)
    end
  end

  def promote(conn, %{"id" => id}) do
    user = Coherence.current_user(conn)
    question = conn.params["question_id"] |> Questions.get_question!()
    new_best_response = Responses.get_response!(id)
    previous_best_response = Responses.best_response(question)
    case Responses.promote_response(question, new_best_response) do
      {:ok, new_best_response} ->

        if previous_best_response != nil do
          Accounts.subtract_rep(previous_best_response, Responses.associated_user(previous_best_response), "reject", "posting")
          user = Accounts.get_user!(user.id)
          Accounts.subtract_rep(previous_best_response, user, "reject", "question_owner")
        end

        user = Accounts.get_user!(user.id)
        Accounts.add_rep(new_best_response, user, "accept", "question_owner")
        Accounts.add_rep(new_best_response, Responses.associated_user(new_best_response), "accept", "posting")

        conn
        |> put_flash(:info, "Response promoted successfully.")
        |> redirect(to: question_path(conn, :show, question))
      {:error, %Ecto.Changeset{} = response_changeset} ->
        comment_changeset = Comments.change_comment()
        conn
        |> put_flash(:info, "Response not promoted successfully")
        render(conn, SlimOverflowWeb.QuestionView, "show.html", response_changeset: response_changeset,
        comment_changeset: comment_changeset, question: question)
    end
  end

  def upvote(conn, %{"id" => id}) do
    user = Coherence.current_user(conn)
    response = Responses.get_response!(id)
    upvote_successful = Responses.upvote_response(response, user)
    posting_user = Responses.associated_user(response)

    if upvote_successful do
      Accounts.add_rep(response, posting_user, "upvote", "posting")
      Accounts.add_rep(response, user, "upvote", "voting")
    end

    conn |> json %{ upvote_successful: upvote_successful}
  end

  def downvote(conn, %{"id" => id}) do
    user = Coherence.current_user(conn)
    response = Responses.get_response!(id)
    downvote_successful = Responses.downvote_response(response, user)
    posting_user = Responses.associated_user(response)

    if downvote_successful do
      Accounts.subtract_rep(response, posting_user, "downvote", "posting")
      Accounts.subtract_rep(response, user, "downvote", "voting")
    end

    conn |> json %{ downvote_successful: downvote_successful}
  end
end
