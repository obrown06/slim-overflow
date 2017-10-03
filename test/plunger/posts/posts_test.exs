defmodule Plunger.PostsTest do
  use Plunger.DataCase

  alias Plunger.Posts

  describe "questions" do
    alias Plunger.Posts.Question

    @valid_attrs %{body: "some body", title: "some title"}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    def question_fixture(attrs \\ %{}) do
      {:ok, question} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_question()

      question
    end

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Posts.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Posts.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      assert {:ok, %Question{} = question} = Posts.create_question(@valid_attrs)
      assert question.body == "some body"
      assert question.title == "some title"
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      assert {:ok, question} = Posts.update_question(question, @update_attrs)
      assert %Question{} = question
      assert question.body == "some updated body"
      assert question.title == "some updated title"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_question(question, @invalid_attrs)
      assert question == Posts.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Posts.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Posts.change_question(question)
    end
  end

  describe "categories" do
    alias Plunger.Posts.Category

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Posts.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Posts.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Posts.create_category(@valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, category} = Posts.update_category(category, @update_attrs)
      assert %Category{} = category
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_category(category, @invalid_attrs)
      assert category == Posts.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Posts.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Posts.change_category(category)
    end
  end

  describe "responses" do
    alias Plunger.Posts.Response

    @valid_attrs %{description: "some description"}
    @update_attrs %{description: "some updated description"}
    @invalid_attrs %{description: nil}

    def response_fixture(attrs \\ %{}) do
      {:ok, response} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_response()

      response
    end

    test "list_responses/0 returns all responses" do
      response = response_fixture()
      assert Posts.list_responses() == [response]
    end

    test "get_response!/1 returns the response with given id" do
      response = response_fixture()
      assert Posts.get_response!(response.id) == response
    end

    test "create_response/1 with valid data creates a response" do
      assert {:ok, %Response{} = response} = Posts.create_response(@valid_attrs)
      assert response.description == "some description"
    end

    test "create_response/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_response(@invalid_attrs)
    end

    test "update_response/2 with valid data updates the response" do
      response = response_fixture()
      assert {:ok, response} = Posts.update_response(response, @update_attrs)
      assert %Response{} = response
      assert response.description == "some updated description"
    end

    test "update_response/2 with invalid data returns error changeset" do
      response = response_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_response(response, @invalid_attrs)
      assert response == Posts.get_response!(response.id)
    end

    test "delete_response/1 deletes the response" do
      response = response_fixture()
      assert {:ok, %Response{}} = Posts.delete_response(response)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_response!(response.id) end
    end

    test "change_response/1 returns a response changeset" do
      response = response_fixture()
      assert %Ecto.Changeset{} = Posts.change_response(response)
    end
  end
end
