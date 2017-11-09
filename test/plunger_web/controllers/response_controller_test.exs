defmodule PlungerWeb.ResponseControllerTest do
  use PlungerWeb.ConnCase

  alias Plunger.Responses

  @create_attrs %{description: "some response description"}
  @update_attrs %{description: "some updated description"}
  @invalid_attrs %{description: nil}

  def fixture(:response) do
    {:ok, response} = Posts.create_response(@create_attrs)
    response
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
      user = insert_user(%{email: email})
      category = insert_category()
      question = insert_question(user, category)
      response = insert_response(user, question)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user, question: question, response: response}
    else
      :ok
    end
  end

  #describe "index" do
  #  test "lists all responses", %{conn: conn} do
  #    conn = get conn, response_path(conn, :index)
  #    assert html_response(conn, 200) =~ "Listing Responses"
  #  end
  #end

  #describe "new response" do
  #  test "renders form", %{conn: conn} do
  #    conn = get conn, response_path(conn, :new)
  #    assert html_response(conn, 200) =~ "New Response"
  #  end
  #end

  describe "create response" do
    @tag login_as: "test@test.com"
    test "redirects to show when data is valid", %{conn: conn, question: question} do
      conn = post conn, response_path(conn, :create), response: @create_attrs, question_id: question.id

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      conn = refresh_assigns(conn)
      conn = get conn, question_path(conn, :show, question.id)
      assert html_response(conn, 200) =~ "some response description"
    end

    @tag login_as: "test@test.com"
    test "renders errors when data is invalid", %{conn: conn, question: question} do
      conn = post conn, response_path(conn, :create), response: @invalid_attrs, question_id: question.id
      assert html_response(conn, 200) =~ "Show Question"
    end
  end

  describe "upvote response" do

    @tag login_as: "test@test.com"
    test ":votes is initialized to zero", %{response: response} do
      assert 0 == get_num_votes(response)
    end

    @tag login_as: "test@test.com"
    test "upvoting a response increments its vote count", %{conn: conn, question: question, response: response} do
      assert 0 == get_num_votes(response)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      get conn, response_path(conn, :upvote, response), question_id: question.id
      assert 1 == get_num_votes(response)
    end

    @tag login_as: "test@test.com"
    test "upvoting a response after its response_votes :votes count is set to 1 has no effect", %{conn: conn, question: question, response: response} do
      assert 0 == get_num_votes(response)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, response_path(conn, :upvote, response), question_id: question.id
      assert 1 == get_num_votes(response)
      get conn, question_path(conn, :upvote, response), question_id: question.id
      assert 1 == get_num_votes(response)
    end
  end

  describe "downvote response" do

    @tag login_as: "test@test.com"
    test "downvoting a response decrements its vote count", %{conn: conn, question: question, response: response} do
      assert 0 == get_num_votes(response)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, response_path(conn, :downvote, response), question_id: question.id
      assert -1 == get_num_votes(response)
    end

    @tag login_as: "test@test.com"
    test "downvoting a response after its response_vote :votes count is set to -1 has no effect", %{conn: conn, question: question, response: response} do
      assert 0 == get_num_votes(response)
      conn = get conn, question_path(conn, :show, question)
      conn = refresh_assigns(conn)
      conn = get conn, response_path(conn, :downvote, response), question_id: question.id
      assert -1 == get_num_votes(response)
      get conn, response_path(conn, :downvote, response), question_id: question.id
      assert -1 == get_num_votes(response)
    end
  end

  describe "promote response" do

    @tag login_as: "test@test.com"
    test "promoting a response marks it as a best response", %{conn: conn, question: question, response: response} do
      assert response.is_best == false
      conn = get conn, response_path(conn, :promote, response, question_id: question.id)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      response = Responses.get_response!(response.id)
      assert response.is_best == true
    end

    @tag login_as: "test@test.com"
    test "promoting a response demotes other responses", %{user: user, conn: conn, question: question, response: response} do
      assert response.is_best == false
      conn = get conn, response_path(conn, :promote, response, question_id: question.id)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      response = Responses.get_response!(response.id)
      assert response.is_best == true

      conn = refresh_assigns(conn)

      new_best_response = insert_response(user, question, %{"description" => "new best response"})
      conn = get conn, response_path(conn, :promote, new_best_response, question_id: question.id)
      assert redirected_to(conn) == question_path(conn, :show, question.id)
      new_best_response = Responses.get_response!(new_best_response.id)
      old_best_response = Responses.get_response!(response.id)
      assert new_best_response.is_best == true
      assert old_best_response.is_best == false
    end
  end

  @tag login_as: "test@test.com"
  test "requires user authentication on all actions", %{conn: conn, response: response, question: question} do
    conn = recycle(conn)
    Enum.each([
      get(conn, response_path(conn, :upvote, response), question_id: question.id),
      get(conn, response_path(conn, :downvote, question), question_id: question.id),
      post(conn, response_path(conn, :create), response: @create_attrs),
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end

  #describe "edit response" do
  #  setup [:create_response]

  #  test "renders form for editing chosen response", %{conn: conn, response: response} do
  #    conn = get conn, response_path(conn, :edit, response)
  #    assert html_response(conn, 200) =~ "Edit Response"
  #  end
  #end

  #describe "update response" do
  #  setup [:create_response]

  #  test "redirects when data is valid", %{conn: conn, response: response} do
  #    conn = put conn, response_path(conn, :update, response), response: @update_attrs
  #    assert redirected_to(conn) == response_path(conn, :show, response)

  #    conn = get conn, response_path(conn, :show, response)
  #    assert html_response(conn, 200) =~ "some updated description"
  #  end

  #  test "renders errors when data is invalid", %{conn: conn, response: response} do
  #    conn = put conn, response_path(conn, :update, response), response: @invalid_attrs
  #    assert html_response(conn, 200) =~ "Edit Response"
  #  end
  #end

  #describe "delete response" do
  #  setup [:create_response]

  #  test "deletes chosen response", %{conn: conn, response: response} do
  #    conn = delete conn, response_path(conn, :delete, response)
  #    assert redirected_to(conn) == response_path(conn, :index)
  #    assert_error_sent 404, fn ->
  #      get conn, response_path(conn, :show, response)
  #    end
  #  end
  #end

  defp create_response(_) do
    response = fixture(:response)
    {:ok, response: response}
  end
end
