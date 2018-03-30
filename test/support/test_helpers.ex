defmodule SlimOverflow.TestHelpers do
  alias SlimOverflow.Repo
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Questions
  alias SlimOverflow.Questions.QuestionVote
  alias SlimOverflow.Responses
  alias SlimOverflow.Responses.Response
  alias SlimOverflow.Responses.ResponseVote
  alias SlimOverflow.Comments
  alias SlimOverflow.Comments.Comment
  alias SlimOverflow.Comments.CommentVote
  alias SlimOverflow.Accounts
  import Ecto.Query, only: [from: 2]

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{name: "Test User",
    email: "test@test.com",
    password: "test123",
    confirmed_at: Timex.now,
    }, attrs)

    {:ok, user} = Accounts.create_user(changes)

    user
  end

  def insert_admin_user(attrs \\ %{}) do
    changes = Map.merge(%{name: "Admin Test User",
    email: "admin@admin.com",
    password: "test123",
    confirmed_at: Timex.now,
    }, attrs)

    {:ok, user} = Accounts.create_user(changes)

    user
    |> Ecto.Changeset.change(is_admin: true)
    |> Repo.update

    Accounts.get_user!(user.id)
  end

  def insert_category(attrs \\ %{}) do
    changes = Map.merge(%{name: "Test Category",
    }, attrs)

    {:ok, category} =
      %SlimOverflow.Categories.Category{}
      |> SlimOverflow.Categories.Category.changeset(changes)
      |> Repo.insert()

    category
  end

  def get_num_votes(%Question{} = question) do
    sum = Repo.aggregate((from qv in QuestionVote, where: qv.question_id == ^question.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

  def get_num_votes(%Response{} = response) do
    sum = Repo.aggregate((from rv in ResponseVote, where: rv.response_id == ^response.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

  def get_num_votes(%Comment{} = comment) do
    sum = Repo.aggregate((from cv in CommentVote, where: cv.comment_id == ^comment.id), :sum, :votes)
    case sum do
      nil -> 0
      _ -> sum
    end
  end

  def insert_question(user, category, attrs \\ %{}) do
    valid_attrs = %{"body" => "some body", "title" => "some title"}
    category_attrs = %{"categories" => [Integer.to_string(category.id)]}
    {:ok, question} =
      attrs
      |> Enum.into(category_attrs)
      |> Enum.into(valid_attrs)
      |> Questions.create_question(user)

    question
  end

  def insert_response(user, question, attrs \\ %{}) do
    valid_attrs = %{"description" => "some description"}
    {:ok, response} = Responses.create_response(user, question, attrs |> Enum.into(valid_attrs))

    response = Responses.get_response!(response.id) |> Repo.preload(:user)
  end

  def insert_comment_on_question(user, question, attrs \\ %{}) do
    valid_attrs = %{"comment" => %{"description" => "some description"}, "parent_type" => "question", "question_id" => question.id}

    {:ok, comment} = Comments.create_comment(user, attrs |> Enum.into(valid_attrs))

    comment = Comments.get_comment!(comment.id) |> Repo.preload(:user)
  end

  def insert_comment_on_response(user, response, attrs \\ %{}) do
    valid_attrs = %{"comment" => %{"description" => "some description"}, "parent_type" => "response", "response_id" => response.id}

    {:ok, comment} = Comments.create_comment(user, attrs |> Enum.into(valid_attrs))

    comment = Comments.get_comment!(comment.id) |> Repo.preload(:user)
  end

  def insert_comment_on_comment(user, comment, attrs \\ %{}) do
    valid_attrs = %{"comment" => %{"description" => "some description"}, "parent_type" => "comment", "comment_id" => comment.id}

    {:ok, comment} = Comments.create_comment(user, attrs |> Enum.into(valid_attrs))

    comment = Comments.get_comment!(comment.id) |> Repo.preload(:user)
  end

end
