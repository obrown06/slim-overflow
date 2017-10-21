defmodule Plunger.CommentsTest do
  use Plunger.DataCase

  alias Plunger.Responses
  alias Plunger.Comments
  alias Plunger.Accounts
  alias Plunger.Questions

  setup do
    user = insert_user()
    category = insert_category()
    question = insert_question(user, category)
    response = insert_response(user, question)
    comment_on_question = insert_comment_on_question(user, question)
    comment_on_response = insert_comment_on_response(user, response)
    comment_on_comment = insert_comment_on_comment(user, comment_on_question)
    #conn = assign(conn(), :current_user, user)
    {:ok, category: category, question: question, user: user, response: response, comment_on_question: comment_on_question,
        comment_on_response: comment_on_response, comment_on_comment: comment_on_comment}
  end

  describe "comments" do
    alias Plunger.Comments.Comment

    @valid_attrs %{"comment" => %{"description" => "some description"}}
    @update_attrs %{"description" => "some updated description"}
    @invalid_attrs %{"comment" => %{"description" => nil}}

    test "list_comments/0 returns all comments", %{comment_on_question: comment_on_question,
        comment_on_response: comment_on_response, comment_on_comment: comment_on_comment} do

      comments =
        Comments.list_comments()
        |> Enum.map(&Repo.preload(&1, :user))
      assert comments == [comment_on_question, comment_on_response, comment_on_comment]
    end

    test "get_comment!/1 returns the comment with given id", %{comment_on_question: comment_on_question} do
      assert Comments.get_comment!(comment_on_question.id) |> Repo.preload(:user) == comment_on_question
    end

    test "create_comment/2 on a question with valid data creates a comment", %{question: question, user: user} do
      comment_attrs = %{"parent_type" => "question", "question_id" => question.id}
      assert {:ok, %Comment{} = comment_on_question} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      assert comment_on_question.description == "some description"
    end

    test "create_comment/2 on a response with valid data creates a comment", %{response: response, user: user} do
      comment_attrs = %{"parent_type" => "response", "response_id" => response.id}
      assert {:ok, %Comment{} = comment_on_response} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      assert comment_on_response.description == "some description"
    end

    test "create_comment/2 on a comment with valid data creates a comment", %{comment_on_question: comment, user: user} do
      comment_attrs = %{"parent_type" => "comment", "comment_id" => comment.id}
      assert {:ok, %Comment{} = comment_on_comment} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      assert comment_on_comment.description == "some description"
    end

    test "create_comment/2 on a question with invalid data returns error changeset", %{question: question, user: user} do
      comment_attrs = %{"parent_type" => "question", "question_id" => question.id}
      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(user, @invalid_attrs |> Enum.into(comment_attrs))
    end

    test "create_comment/2 on a response with invalid data returns error changeset", %{response: response, user: user} do
      comment_attrs = %{"parent_type" => "response", "response_id" => response.id}
      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(user, @invalid_attrs |> Enum.into(comment_attrs))
    end

    test "create_comment/2 on a comment with invalid data returns error changeset", %{comment_on_question: comment, user: user} do
      comment_attrs = %{"parent_type" => "comment", "comment_id" => comment.id}
      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(user, @invalid_attrs |> Enum.into(comment_attrs))
    end

    test "create_comment/2 on a question associates comment with question", %{question: question, user: user} do
      comment_attrs = %{"parent_type" => "question", "question_id" => question.id}
      assert {:ok, %Comment{} = comment} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      question = Questions.get_question!(question.id) |> Repo.preload(:comments)
      comment = comment |> Repo.preload(:question)
      assert comment.question.id == question.id
      assert Enum.any?(question.comments, fn(c) -> c.id == comment.id end)
    end

    test "create_comment/2 on a question associates comment with user", %{question: question, user: user} do
      comment_attrs = %{"parent_type" => "question", "question_id" => question.id}
      assert {:ok, %Comment{} = comment} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      user = Accounts.get_user!(user.id) |> Repo.preload(:comments)
      comment = comment |> Repo.preload(:user)
      assert comment.user.id == user.id
      assert Enum.any?(user.comments, fn(c) -> c.id == comment.id end)
    end

    test "create_comment/2 on a response associates comment with response", %{response: response, user: user} do
      comment_attrs = %{"parent_type" => "response", "response_id" => response.id}
      assert {:ok, %Comment{} = comment} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      response = Responses.get_response!(response.id) |> Repo.preload(:comments)
      comment = comment |> Repo.preload(:response)
      assert comment.response.id == response.id
      assert Enum.any?(response.comments, fn(c) -> c.id == comment.id end)
    end

    test "create_comment/2 on a response associates comment with user", %{response: response, user: user} do
      comment_attrs = %{"parent_type" => "response", "response_id" => response.id}
      assert {:ok, %Comment{} = comment} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      user = Accounts.get_user!(user.id) |> Repo.preload(:comments)
      comment = comment |> Repo.preload(:user)
      assert comment.user.id == user.id
      assert Enum.any?(user.comments, fn(c) -> c.id == comment.id end)
    end

    test "create_comment/2 on a comment associates comment with comment", %{comment_on_question: parent, user: user} do
      comment_attrs = %{"parent_type" => "comment", "comment_id" => parent.id}
      assert {:ok, %Comment{} = child} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      parent = Comments.get_comment!(parent.id) |> Repo.preload(:comments)
      child = child |> Repo.preload(:parent)
      assert child.parent.id == parent.id
      assert Enum.any?(parent.comments, fn(c) -> c.id == child.id end)
    end

    test "create_comment/2 on a comment associates comment with user", %{comment_on_question: parent, user: user} do
      comment_attrs = %{"parent_type" => "comment", "comment_id" => parent.id}
      assert {:ok, %Comment{} = child} = Comments.create_comment(user, @valid_attrs |> Enum.into(comment_attrs))
      user = Accounts.get_user!(user.id) |> Repo.preload(:comments)
      child = child |> Repo.preload(:user)
      assert child.user.id == user.id
      assert Enum.any?(user.comments, fn(c) -> c.id == child.id end)
    end

    test "change_comment/1 returns a comment changeset", %{comment_on_question: comment_on_question} do
      assert %Ecto.Changeset{} = Comments.change_comment(comment_on_question)
    end

    test ":votes is initialized to zero", %{comment_on_question: comment} do
      assert 0 == get_num_votes(comment)
    end

    test "upvoting a comment increments its vote count", %{comment_on_question: comment, user: user} do
      assert 0 == get_num_votes(comment)
      Comments.upvote_comment!(comment.id, user.id)
      assert 1 == get_num_votes(comment)
    end

    test "downvoting a comment decrements its vote count", %{comment_on_question: comment, user: user} do
      assert 0 == get_num_votes(comment)
      Comments.downvote_comment!(comment.id, user.id)
      assert -1 == get_num_votes(comment)
    end

    test "upvoting a comment after its comment_votes :votes count is set to 1 has no effect", %{comment_on_question: comment, user: user} do
      assert 0 == get_num_votes(comment)
      Comments.upvote_comment!(comment.id, user.id)
      assert 1 == get_num_votes(comment)
      Comments.upvote_comment!(comment.id, user.id)
      assert 1 == get_num_votes(comment)
    end

    test "downvoting a comment after its comment_votes :votes count is set to -1 has no effect", %{comment_on_question: comment, user: user} do
      assert 0 == get_num_votes(comment)
      Comments.downvote_comment!(comment.id, user.id)
      assert -1 == get_num_votes(comment)
      Comments.downvote_comment!(comment.id, user.id)
      assert -1 == get_num_votes(comment)
    end
  end
end
