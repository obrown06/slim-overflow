defmodule Plunger.Accounts.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Accounts.User

  schema "users" do
    field :avatar, PlungerWeb.Avatar.Type
    field :email, :string
    field :name, :string
    field :is_admin, :boolean, default: false
    #field :email_verified, :boolean
    #field :username, :string
    #field :password, :string, virtual: true
    #field :password_hash, :string

    has_many :authorizations, Plunger.Accounts.Authorization, on_delete: :delete_all

    has_many :responses, Plunger.Responses.Response, on_delete: :delete_all
    has_many :response_votes, Plunger.Responses.ResponseVote, on_delete: :delete_all

    has_many :questions, Plunger.Questions.Question, on_delete: :delete_all
    has_many :question_votes, Plunger.Questions.QuestionVote, on_delete: :delete_all

    has_many :comments, Plunger.Comments.Comment, on_delete: :delete_all
    has_many :comment_votes, Plunger.Comments.CommentVote, on_delete: :delete_all

    timestamps()
  end

  @required_fields ~w(email name)
  @optional_fields ~w()

  @required_file_fields ~w()
  @optional_file_fields ~w(avatar)

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields, @optional_fields)
    |> cast_attachments(attrs, @optional_file_fields)
    |> validate_format(:email, ~r/@/)
    #|> cast_attachments(attrs, @required_file_fields, @optional_file_fields)
    #|> cast(attrs, [:email, :username, :name])
    #|> validate_required([:email, :username, :name])
    #|> unique_constraint(:email)
    #|> unique_constraint(:username)
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> cast_attachments(attrs, @optional_file_fields)
    #user
    #|> changeset(attrs)
    #|> cast(attrs, [:password])
    #|> validate_length(:password, min: 6, max: 100)
    #|> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
