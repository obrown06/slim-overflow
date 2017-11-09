defmodule Plunger.ResponsesTest do
  use Plunger.DataCase

  alias Plunger.Responses
  alias Plunger.Questions
  alias Plunger.Accounts

  setup do
    user = insert_user()
    category = insert_category()
    question = insert_question(user, category)
    response = insert_response(user, question)
    #conn = assign(conn(), :current_user, user)
    {:ok, category: category, question: question, user: user, response: response}
  end

  describe "responses" do
    alias Plunger.Responses.Response

    @valid_attrs %{"description" => "some description"}
    @update_attrs %{"description" => "some updated description"}
    @invalid_attrs %{"description" => nil}

    test "list_responses/0 returns all responses", %{response: response} do
      responses =
        Responses.list_responses()
        |> Enum.map(&Repo.preload(&1, :user))
      assert responses == [response]
    end

    test "get_response!/1 returns the response with given id", %{response: response} do
      assert Responses.get_response!(response.id)|> Repo.preload(:user) == response
    end

    test "create_response/1 with valid data creates a response", %{question: question, user: user} do
      assert {:ok, %Response{} = response} = Responses.create_response(user, question, @valid_attrs)
      assert response.description == "some description"
    end

    test "create_response/1 with invalid data returns error changeset", %{question: question, user: user} do
      assert {:error, %Ecto.Changeset{}} = Responses.create_response(user, question, @invalid_attrs)
    end

    test "create_response/1 associates response with question", %{question: question, user: user} do
      assert {:ok, %Response{} = response} = Responses.create_response(user, question, @valid_attrs)
      question = Questions.get_question!(question.id) |> Repo.preload(:responses)
      response = response |> Repo.preload(:question)
      assert response.question.id == question.id
      assert Enum.any?(question.responses, fn(r) -> r.id == response.id end)
    end

    test "create_response/1 associates response with user", %{question: question, user: user} do
      assert {:ok, %Response{} = response} = Responses.create_response(user, question, @valid_attrs)
      user = Accounts.get_user!(user.id) |> Repo.preload(:responses)
      response = response |> Repo.preload(:user)
      assert response.user.id == user.id
      assert Enum.any?(user.responses, fn(r) -> r.id == response.id end)
    end

    test "update_response/2 with valid data updates the response",  %{response: response} do
      assert {:ok, response} = Responses.update_response(response, @update_attrs)
      assert %Response{} = response
      assert response.description == "some updated description"
    end

    test "update_response/2 with invalid data returns error changeset", %{response: response} do
      assert {:error, %Ecto.Changeset{}} = Responses.update_response(response, @invalid_attrs)
      assert response == Responses.get_response!(response.id) |> Repo.preload(:user)
    end

    test "delete_response/1 deletes the response", %{response: response} do
      assert {:ok, %Response{}} = Responses.delete_response(response)
      assert_raise Ecto.NoResultsError, fn -> Responses.get_response!(response.id) end
    end

    test "delete_question/1 removes association between response and user", %{response: response, user: user} do
      assert {:ok, %Response{}} = Responses.delete_response(response)
      user = Accounts.get_user!(user.id) |> Repo.preload(:responses)
      assert !Enum.any?(user.responses, fn(r) -> r.id == response.id end)
    end

    test "delete_question/1 removes association between response and question", %{response: response, question: question} do
      assert {:ok, %Response{}} = Responses.delete_response(response)
      question = Questions.get_question!(question.id) |> Repo.preload(:responses)
      assert !Enum.any?(question.responses, fn(r) -> r.id == response.id end)
    end

    test "change_response/1 returns a response changeset", %{response: response} do
      assert %Ecto.Changeset{} = Responses.change_response(response)
    end

    test ":votes is initialized to zero", %{response: response} do
      assert 0 == get_num_votes(response)
    end

    test "upvoting a response increments its vote count", %{response: response, user: user} do
      assert 0 == get_num_votes(response)
      Responses.upvote_response!(response.id, user.id)
      assert 1 == get_num_votes(response)
    end

    test "downvoting a response decrements its vote count", %{response: response, user: user} do
      assert 0 == get_num_votes(response)
      Responses.downvote_response!(response.id, user.id)
      assert -1 == get_num_votes(response)
    end

    test "upvoting a response after its response_votes :votes count is set to 1 has no effect", %{response: response, user: user} do
      assert 0 == get_num_votes(response)
      Responses.upvote_response!(response.id, user.id)
      assert 1 == get_num_votes(response)
      Responses.upvote_response!(response.id, user.id)
      assert 1 == get_num_votes(response)
    end

    test "downvoting a response after its response_votes :votes count is set to -1 has no effect", %{response: response, user: user} do
      assert 0 == get_num_votes(response)
      Responses.downvote_response!(response.id, user.id)
      assert -1 == get_num_votes(response)
      Responses.downvote_response!(response.id, user.id)
      assert -1 == get_num_votes(response)
    end

    test "promote response promotes it to best response", %{response: response, question: question, user: user} do
      assert response.is_best == false
      Responses.promote_response(question, response)
      response = Responses.get_response!(response.id)
      assert response.is_best == true

      question = Repo.preload(question, :responses)
      best_response_list = Enum.filter(question.responses, fn(r) -> r.is_best == true end)
      assert best_response_list = [response]
    end

    test "promoting response demotes previous best response", %{response: response, question: question, user: user} do
      assert response.is_best == false
      {:ok, response} = Responses.promote_response(question, response)
      response = Responses.get_response!(response.id)
      assert response.is_best == true

      new_response = insert_response(user, question, %{"description" => "some other description"})
      assert new_response.is_best == false
      Responses.promote_response(question, new_response)
      new_best_response = Responses.get_response!(new_response.id)
      assert new_best_response.is_best == true
      old_best_response = Responses.get_response!(response.id)
      assert old_best_response.is_best == false

      question = Repo.preload(question, :responses)
      best_response_list = Enum.filter(question.responses, fn(r) -> r.is_best == true end)
      assert best_response_list == [new_best_response]
    end
  end

end
