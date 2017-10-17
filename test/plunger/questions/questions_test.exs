defmodule Plunger.QuestionsTest do
  use Plunger.DataCase
  alias Plunger.Questions

  #setup do
  #  user = insert_user(username: "nick")
  #  conn = assign(conn(), :current_user, user)
  #  {:ok, conn: conn, user: user}
  #end

  describe "questions" do
    alias Plunger.Questions.Question

    @valid_attrs %{body: "some body", title: "some title", categories: [name: "Test Category"]}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    def question_fixture(attrs \\ %{}) do
      user = insert_user()
      category = insert_category()
      {:ok, question} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Questions.create_question(user)

      question
    end

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Questions.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Questions.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      user = insert_user()
      assert {:ok, %Question{} = question} = Questions.create_question(@valid_attrs, user)
      assert question.body == "some body"
      assert question.title == "some title"
    end

    test "create_question/1 with invalid data returns error changeset" do
      user = insert_user()
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@invalid_attrs, user)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      assert {:ok, question} = Questions.update_question(question, @update_attrs)
      assert %Question{} = question
      assert question.body == "some updated body"
      assert question.title == "some updated title"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @invalid_attrs)
      assert question == Questions.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Questions.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end
  end
end
