defmodule SlimOverflowWeb.CommentControllerTest do
  use SlimOverflowWeb.ConnCase

  alias SlimOverflow.Posts

  @create_attrs %{description: "some comment description"}
  @update_attrs %{description: "some updated description"}
  @invalid_attrs %{description: nil}

  def fixture(:comment) do
    {:ok, comment} = Posts.create_comment(@create_attrs)
    comment
  end

  def refresh_assigns(%Plug.Conn{} = conn) do
    saved_assigns = conn.assigns
    conn =
      conn
      |> recycle()
      |> Map.put(:assigns, saved_assigns)
  end

  setup %{conn: conn} = config do
    if email = config[:login_as] do
      user = insert_user(%{email: email, password: "test123"})
      category = insert_category()
      question = insert_question(user, category)
      response = insert_response(user, question)
      comment_on_question = insert_comment_on_question(user, question)
      comment_on_response = insert_comment_on_response(user, response)
      comment_on_comment = insert_comment_on_comment(user, comment_on_question)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user, question: question, response: response, comment_on_question: comment_on_question,
       comment_on_comment: comment_on_comment, comment_on_response: comment_on_response}
    else
      :ok
    end
  end

  #describe "index" do
  #  test "lists all comments", %{conn: conn} do
  #    conn = get conn, comment_path(conn, :index)
  #    assert html_response(conn, 200) =~ "Listing Comments"
  #  end
  #end

  #describe "new comment" do
  #  test "renders form", %{conn: conn} do
  #    conn = get conn, comment_path(conn, :new)
  #    assert html_response(conn, 200) =~ "New Comment"
  #  end
  #end

  describe "create comment_on_question" do
    @tag login_as: "test@test.com"
    test "redirects to show when data is valid", %{conn: conn, question: question} do
      conn = post conn, comment_path(conn, :create, parent_type: "question", question_id: question.id), comment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :show, question.id)
      assert html_response(conn, 200) =~ "some comment description"
    end


    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn, question: question} do
      conn = post conn, comment_path(conn, :create, parent_type: "question", question_id: question.id), comment: @invalid_attrs
      assert html_response(conn, 200) =~ "Show Question"
    end
  end

  describe "create comment_on_response" do
    @tag login_as: "test@test.com"
    test "redirects to show when data is valid", %{conn: conn, question: question, response: response} do
      conn = post conn, comment_path(conn, :create, parent_type: "response", response_id: response.id, question_id: question.id), comment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :show, question.id)
      assert html_response(conn, 200) =~ "some comment description"
    end


    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn, response: response, question: question} do
      conn = post conn, comment_path(conn, :create, parent_type: "response", response_id: response.id, question_id: question.id), comment: @invalid_attrs
      assert html_response(conn, 200) =~ "Show Question"
    end
  end

  describe "create comment_on_comment" do
    @tag login_as: "test@test.com"
    test "redirects to show when data is valid", %{conn: conn, comment_on_question: comment_on_question, question: question} do
      conn = post conn, comment_path(conn, :create, parent_type: "comment", question_id: question.id, comment_id: comment_on_question.id), comment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :show, question.id)
      assert html_response(conn, 200) =~ "some comment description"
    end


    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn, question: question, comment_on_question: comment_on_question} do
      conn = post conn, comment_path(conn, :create, parent_type: "comment", comment_id: comment_on_question.id, question_id: question.id), comment: @invalid_attrs
      assert html_response(conn, 200) =~ "Show Question"
    end
  end


  describe "upvote comment" do

    @tag login_as: "test@test.com"
    test ":votes is initialized to zero", %{comment_on_question: comment} do
      assert 0 == get_num_votes(comment)
    end

    @tag login_as: "test@test.com"
    test "upvoting a comment increments its vote count", %{conn: conn, question: question, comment_on_question: comment} do
      assert 0 == get_num_votes(comment)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      get conn, comment_path(conn, :upvote, comment), question_id: question.id
      assert 1 == get_num_votes(comment)
    end

    @tag login_as: "test@test.com"
    test "upvoting a comment after its comment_votes :votes count is set to 1 has no effect", %{conn: conn, question: question, comment_on_question: comment} do
      assert 0 == get_num_votes(comment)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, comment_path(conn, :upvote, comment), question_id: question.id
      assert 1 == get_num_votes(comment)
      conn = refresh_assigns(conn)
      get conn, comment_path(conn, :upvote, comment), question_id: question.id
      assert 1 == get_num_votes(comment)
    end
  end

  describe "downvote comment" do

    @tag login_as: "test@test.com"
    test "downvoting a comment decrements its vote count", %{conn: conn, question: question, comment_on_question: comment} do
      assert 0 == get_num_votes(comment)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      get conn, comment_path(conn, :downvote, comment), question_id: question.id
      assert -1 == get_num_votes(comment)
    end

    @tag login_as: "test@test.com"
    test "downvoting a comment after its comment_vote :votes count is set to -1 has no effect", %{conn: conn, question: question, comment_on_question: comment} do
      assert 0 == get_num_votes(comment)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, comment_path(conn, :downvote, comment), question_id: question.id
      assert -1 == get_num_votes(comment)
      conn = refresh_assigns(conn)
      get conn, comment_path(conn, :downvote, comment), question_id: question.id
      assert -1 == get_num_votes(comment)
    end
  end

  @tag login_as: "test@test.com"
  test "requires user authentication on all actions", %{conn: conn, response: response, question: question, comment_on_question: comment} do
    conn = recycle(conn)
    Enum.each([
      get(conn, comment_path(conn, :upvote, comment), question_id: question.id),
      get(conn, comment_path(conn, :downvote, comment), question_id: question.id),
      post(conn, comment_path(conn, :create), comment: @create_attrs),
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end

  #describe "edit comment" do
  #  setup [:create_comment]

  #  test "renders form for editing chosen comment", %{conn: conn, comment: comment} do
  #    conn = get conn, comment_path(conn, :edit, comment)
  #    assert html_response(conn, 200) =~ "Edit Comment"
  #  end
  #end

  #describe "update comment" do
  #  setup [:create_comment]

  #  test "redirects when data is valid", %{conn: conn, comment: comment} do
  #    conn = put conn, comment_path(conn, :update, comment), comment: @update_attrs
  #    assert redirected_to(conn) == comment_path(conn, :show, comment)

  #    conn = get conn, comment_path(conn, :show, comment)
  #    assert html_response(conn, 200) =~ "some updated description"
  #  end

  #  test "renders errors when data is invalid", %{conn: conn, comment: comment} do
  #    conn = put conn, comment_path(conn, :update, comment), comment: @invalid_attrs
  #    assert html_response(conn, 200) =~ "Edit Comment"
  #  end
  #end

  #describe "delete comment" do
  #  setup [:create_comment]

  #  test "deletes chosen comment", %{conn: conn, comment: comment} do
  #    conn = delete conn, comment_path(conn, :delete, comment)
  #    assert redirected_to(conn) == comment_path(conn, :index)
  #    assert_error_sent 404, fn ->
  #      get conn, comment_path(conn, :show, comment)
  #    end
  #  end
  #end

  defp create_comment(_) do
    comment = fixture(:comment)
    {:ok, comment: comment}
  end
end
