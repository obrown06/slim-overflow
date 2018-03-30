defmodule SlimOverflowWeb.QuestionControllerTest do
  use SlimOverflowWeb.ConnCase

  alias SlimOverflow.Questions
  import Timex

  @create_attrs %{body: "some body", title: "some title"}
  @update_attrs %{body: "some updated body", title: "some updated title"}
  @invalid_attrs %{body: nil, title: nil}

  def fixture(:question) do
    {:ok, question} = Questions.create_question(@create_attrs)
    question
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
      user = insert_user(%{email: email, password: "test123", confirmed_at: Timex.now})
      conn = assign(conn, :current_user, user)
      category = insert_category()
      question = insert_question(user, category)
      {:ok, conn: conn, user: user, question: question, category: category}
    else
      :ok
    end
  end

  describe "index" do
    @tag login_as: "test@test.com"
    test "lists all questions", %{conn: conn} do
      conn = get conn, question_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Questions"
    end
  end

  describe "new question" do
    @tag login_as: "test@test.com"
    test "renders form", %{conn: conn} do
      conn = get conn, question_path(conn, :new)
      assert html_response(conn, 200) =~ "New Question"
    end
  end

  describe "create question" do
    @tag login_as: "test@test.com"
    test "redirects to show when data is valid", %{conn: conn, category: category} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      conn = post conn, question_path(conn, :create), question: @create_attrs |> Enum.into(valid_category_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == question_path(conn, :show, id)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Question"
    end

    @tag login_as: "test@test.com"
    test "renders errors when question data is invalid", %{conn: conn, category: category} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      conn = post conn, question_path(conn, :create), question: @invalid_attrs |> Enum.into(valid_category_attrs)
      assert html_response(conn, 200) =~ "New Question"
    end

    @tag login_as: "test@test.com"
    test "raises NoResultsError when category data is invalid", %{conn: conn} do
      invalid_category_attrs = %{"categories" => [Integer.to_string(-1)]}
      assert_raise Ecto.NoResultsError, fn -> post conn, question_path(conn, :create), question: @invalid_attrs |> Enum.into(invalid_category_attrs) end
    end

  end

  describe "edit question" do
    #setup [:create_question]
    @tag login_as: "test@test.com"
    test "renders form for editing chosen question", %{conn: conn, question: question} do
      conn = get conn, question_path(conn, :edit, question)
      assert html_response(conn, 200) =~ "Edit Question"
    end

    @tag login_as: "test@test.com"
    test "admins can edit question", %{conn: conn, question: question} do
      nonadmin = insert_user(%{email: "nonadmin@nonadmin.com"})

      conn = assign(conn, :current_user, nonadmin)
      conn = get conn, question_path(conn, :edit, question)
      assert html_response(conn, 302)
      assert conn.halted

      admin = insert_admin_user()
      IO.inspect admin
      conn = assign(conn, :current_user, admin)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :edit, question)
      assert html_response(conn, 200) =~ "Edit Question"
    end

  end

  describe "update question" do
    #setup [:create_question]
    @tag login_as: "test@test.com"
    test "redirects when data is valid", %{conn: conn, question: question, category: category, user: user} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      conn = put conn, question_path(conn, :update, question), question: @update_attrs |> Enum.into(valid_category_attrs)
      assert redirected_to(conn) == question_path(conn, :show, question)

      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :show, question)
      assert html_response(conn, 200) =~ "some updated body"
    end

    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn, question: question, category: category} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      conn = put conn, question_path(conn, :update, question), question: @invalid_attrs |> Enum.into(valid_category_attrs)
      assert html_response(conn, 200) =~ "Edit Question"
    end

    @tag login_as: "test@test.com"
    test "raises NoResultsError when category data is invalid", %{conn: conn, question: question} do
      invalid_category_attrs = %{"categories" => [Integer.to_string(-1)]}
      assert_raise Ecto.NoResultsError, fn -> put conn, question_path(conn, :update, question), question: @update_attrs |> Enum.into(invalid_category_attrs) end
    end
  end

  describe "delete question" do
    #setup [:create_question]

    @tag login_as: "test@test.com"
    test "deletes chosen question", %{conn: conn, question: question} do
      conn = delete conn, question_path(conn, :delete, question)
      assert redirected_to(conn) == question_path(conn, :index)
      conn = refresh_assigns(conn)
      assert_error_sent 404, fn ->
        get conn, question_path(conn, :show, question)
      end
    end
  end

  describe "upvote question" do

    @tag login_as: "test@test.com"
    test ":votes is initialized to zero", %{question: question} do
      assert 0 == get_num_votes(question)
    end

    @tag login_as: "test@test.com"
    test "upvoting a question increments its vote count", %{conn: conn, question: question, user: user} do
      assert 0 == get_num_votes(question)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :upvote, question)
      assert 1 == get_num_votes(question)
    end

    @tag login_as: "test@test.com"
    test "upvoting a question after its question_votes :votes count is set to 1 has no effect", %{conn: conn, question: question, user: user} do
      assert 0 == get_num_votes(question)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :upvote, question)
      conn = refresh_assigns(conn)
      assert 1 == get_num_votes(question)
      conn = get conn, question_path(conn, :upvote, question)
      assert 1 == get_num_votes(question)
    end
  end

  describe "downvote question" do

    @tag login_as: "test@test.com"
    test "downvoting a question decrements its vote count", %{conn: conn, question: question, user: user} do
      assert 0 == get_num_votes(question)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :downvote, question)
      assert -1 == get_num_votes(question)
    end

    @tag login_as: "test@test.com"
    test "downvoting a question after its question_votes :votes count is set to -1 has no effect", %{conn: conn, question: question, user: user} do
      assert 0 == get_num_votes(question)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :downvote, question)
      assert -1 == get_num_votes(question)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :downvote, question)
      assert -1 == get_num_votes(question)
    end
  end

  @tag login_as: "test@test.com"
  test "requires user authentication on actions", %{conn: conn, question: question} do
    conn = recycle(conn)
    Enum.each([
      get(conn, question_path(conn, :new)),
      get(conn, question_path(conn, :upvote, question)),
      get(conn, question_path(conn, :downvote, question)),
      delete(conn, question_path(conn, :delete, question)),
      put(conn, question_path(conn, :update, question)),
      post(conn, question_path(conn, :create), question: @create_attrs),
      get(conn, question_path(conn, :edit, question)),
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end

  @tag login_as: "test@test.com"
  test "authorizes actions against access by other users", %{conn: conn, question: question} do

    non_owner = insert_user(%{email: "sneaky@test.com", name: "sneak", password: "sneak123"})
    conn = get build_conn(), "/"
    conn = assign(conn, :current_user, non_owner)

    conn = get(conn, question_path(conn, :edit, question))
    assert html_response(conn, 302)
    assert conn.halted

    conn = put(conn, question_path(conn, :update, question, video: @valid_attrs))
    assert html_response(conn, 302)
    assert conn.halted

    delete(conn, question_path(conn, :delete, question))
    assert html_response(conn, 302)
    assert conn.halted

  end

  #defp create_question(_) do
  #  question = fixture(:question)
  #  {:ok, question: question}
  #end
end
