defmodule PlungerWeb.QuestionControllerTest do
  use PlungerWeb.ConnCase

  alias Plunger.Posts

  @create_attrs %{body: "some body", title: "some title"}
  @update_attrs %{body: "some updated body", title: "some updated title"}
  @invalid_attrs %{body: nil, title: nil}

  def fixture(:question) do
    {:ok, question} = Posts.create_question(@create_attrs)
    question
  end

  describe "index" do
    test "lists all questions", %{conn: conn} do
      conn = get conn, question_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Questions"
    end
  end

  describe "new question" do
    test "renders form", %{conn: conn} do
      conn = get conn, question_path(conn, :new)
      assert html_response(conn, 200) =~ "New Question"
    end
  end

  describe "create question" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, question_path(conn, :create), question: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == question_path(conn, :show, id)

      conn = get conn, question_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Question"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, question_path(conn, :create), question: @invalid_attrs
      assert html_response(conn, 200) =~ "New Question"
    end
  end

  describe "edit question" do
    setup [:create_question]

    test "renders form for editing chosen question", %{conn: conn, question: question} do
      conn = get conn, question_path(conn, :edit, question)
      assert html_response(conn, 200) =~ "Edit Question"
    end
  end

  describe "update question" do
    setup [:create_question]

    test "redirects when data is valid", %{conn: conn, question: question} do
      conn = put conn, question_path(conn, :update, question), question: @update_attrs
      assert redirected_to(conn) == question_path(conn, :show, question)

      conn = get conn, question_path(conn, :show, question)
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, question: question} do
      conn = put conn, question_path(conn, :update, question), question: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Question"
    end
  end

  describe "delete question" do
    setup [:create_question]

    test "deletes chosen question", %{conn: conn, question: question} do
      conn = delete conn, question_path(conn, :delete, question)
      assert redirected_to(conn) == question_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, question_path(conn, :show, question)
      end
    end
  end

  defp create_question(_) do
    question = fixture(:question)
    {:ok, question: question}
  end
end
