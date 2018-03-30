defmodule SlimOverflow.QuestionsTest do
  use SlimOverflow.DataCase
  alias SlimOverflow.Questions
  alias SlimOverflow.Accounts
  alias SlimOverflow.Categories

  setup do
    user = insert_user()
    category = insert_category()
    question = insert_question(user, category)
    #conn = assign(conn(), :current_user, user)
    {:ok, category: category, question: question, user: user}
  end

  describe "questions" do
    alias SlimOverflow.Questions.Question

    @valid_attrs %{"body" => "some body", "title" => "some title"}
    @update_attrs %{"body" => "some updated body", "title" => "some updated title"}
    @invalid_attrs %{"body" =>  nil, "title" => nil}

    test "list_questions/0 returns all questions", %{question: question} do
      questions =
        Questions.list_questions()
        |> Enum.map(&Repo.preload(&1, :categories))
      assert questions == [question]
    end

    test "list_questions/1 returns all questions associated with a given category", %{question: question, category: category} do
      questions =
        Questions.list_questions(category)
        |> Enum.map(&Repo.preload(&1, :categories))

      assert questions == [question]
    end

    test "list_questions/1 returns empty list when for a category lacking associated questions" do
      category = insert_category(%{name: "Question-less Category"})
      questions = Questions.list_questions(category)

      assert questions == []
    end

    test "get_question!/1 returns the question with given id", %{question: question} do
      assert Questions.get_question!(question.id)|> Repo.preload(:categories) == question
    end

    test "create_question/1 with valid data creates a question", %{category: category, user: user} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}

      assert {:ok, %Question{} = question} = Questions.create_question(@valid_attrs |> Enum.into(valid_category_attrs), user)
      assert question.body == "some body"
      assert question.title == "some title"
      assert question.categories == [category]
    end

    test "create_question/1 with invalid data returns error changeset", %{category: category, user: user} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@invalid_attrs |> Enum.into(valid_category_attrs), user)
    end

    test "create_question/1 with non-existent category id raises Ecto.NoResultsError", %{user: user} do
      invalid_category_attrs = %{"categories" => ["-1"]}
      assert_raise Ecto.NoResultsError, fn -> Questions.create_question(@valid_attrs |> Enum.into(invalid_category_attrs), user) end
    end

    test "create_question/1 with no categories given returns error changeset", %{user: user} do
      empty_category_attrs = %{"categories" => ["", ""]}
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@valid_attrs |> Enum.into(empty_category_attrs), user)
    end

    test "create_question/1 associates question with user", %{category: category, user: user} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      assert {:ok, %Question{} = question} = Questions.create_question(@valid_attrs |> Enum.into(valid_category_attrs), user)
      user = Accounts.get_user!(user.id) |> Repo.preload(:questions)
      question = question |> Repo.preload(:user)
      assert question.user.id == user.id
      assert Enum.any?(user.questions, fn(q) -> q.id == question.id end)
    end

    test "create_question/1 associates question with category", %{category: category, user: user} do
      valid_category_attrs = %{"categories" => [Integer.to_string(category.id)]}
      assert {:ok, %Question{} = question} = Questions.create_question(@valid_attrs |> Enum.into(valid_category_attrs), user)
      category = Categories.get_category!(category.id) |> Repo.preload(:questions)
      question = question |> Repo.preload(:categories)
      assert Enum.any?(question.categories, fn(c) -> c.id == category.id end)
      assert Enum.any?(category.questions, fn(q) -> q.id == question.id end)
    end

    test "update_question/2 with valid data updates the question", %{question: question} do
      updated_category = insert_category(%{name: "Updated Test Category"})
      updated_category_attrs = %{"categories" => [Integer.to_string(updated_category.id)]}
      assert {:ok, question} = Questions.update_question(question, @update_attrs |> Enum.into(updated_category_attrs))
      assert %Question{} = question
      assert question.body == "some updated body"
      assert question.title == "some updated title"
      assert question.categories == [updated_category]
    end

    test "update_question/2 with no categories given returns error changeset", %{question: question} do
      empty_category_attrs = %{"categories" => ["", ""]}
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @valid_attrs |> Enum.into(empty_category_attrs))
      assert question == Questions.get_question!(question.id) |> Repo.preload(:categories)
    end

    test "update_question/2 with invalid data returns error changeset", %{question: question} do
      updated_category = insert_category(%{name: "Updated Test Category"})
      updated_category_attrs = %{"categories" => [Integer.to_string(updated_category.id)]}
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @invalid_attrs |> Enum.into(updated_category_attrs))
      assert question == Questions.get_question!(question.id) |> Repo.preload(:categories)
    end

    test "delete_question/1 deletes the question", %{question: question} do
      assert {:ok, %Question{}} = Questions.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "delete_question/1 removes association between question and user", %{question: question, user: user} do
      assert {:ok, %Question{}} = Questions.delete_question(question)
      user = Accounts.get_user!(user.id) |> Repo.preload(:questions)
      assert !Enum.any?(user.questions, fn(q) -> q.id == question.id end)
    end

    test "delete_question/1 removes association between question and category", %{category: category, question: question} do
      assert {:ok, %Question{}} = Questions.delete_question(question)
      category = Categories.get_category!(category.id) |> Repo.preload(:questions)
      assert !Enum.any?(category.questions, fn(q) -> q.id == question.id end)
    end

    test "change_question/1 returns a question changeset", %{question: question} do
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end

    test ":votes is initialized to zero", %{question: question} do
      assert 0 == get_num_votes(question)
    end

    test "upvoting a question increments its vote count", %{question: question, user: user} do
      assert 0 == get_num_votes(question)
      Questions.upvote_question!(question.id, user.id)
      assert 1 == get_num_votes(question)
    end

    test "downvoting a question decrements its vote count", %{question: question, user: user} do
      assert 0 == get_num_votes(question)
      Questions.downvote_question!(question.id, user.id)
      assert -1 == get_num_votes(question)
    end

    test "upvoting a question after its question_votes :votes count is set to 1 has no effect", %{question: question, user: user} do
      assert 0 == get_num_votes(question)
      Questions.upvote_question!(question.id, user.id)
      assert 1 == get_num_votes(question)
      Questions.upvote_question!(question.id, user.id)
      assert 1 == get_num_votes(question)
    end

    test "downvoting a question after its question_votes :votes count is set to -1 has no effect", %{question: question, user: user} do
      assert 0 == get_num_votes(question)
      Questions.downvote_question!(question.id, user.id)
      assert -1 == get_num_votes(question)
      Questions.downvote_question!(question.id, user.id)
      assert -1 == get_num_votes(question)
    end


  end
end
