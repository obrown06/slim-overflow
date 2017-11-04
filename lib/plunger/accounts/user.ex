defmodule Plunger.Accounts.User do
  use Ecto.Schema
  use Coherence.Schema
  use CoherenceAssent.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Plunger.Accounts.User

  schema "users" do
    field :avatar, PlungerWeb.Avatar.Type
    field :email, :string
    field :name, :string
    #field :username, :string
    #field :password, :string, virtual: true
    #field :password_hash, :string
    field :is_admin, :boolean, default: false
    coherence_schema()
    coherence_assent_schema()

    many_to_many :categories, Plunger.Categories.Category, join_through: "categories_users", on_delete: :delete_all, on_replace: :delete

    #has_many :authorizations, Plunger.Accounts.Authorization, on_delete: :delete_all

    has_many :responses, Plunger.Responses.Response, on_delete: :delete_all
    has_many :response_votes, Plunger.Responses.ResponseVote, on_delete: :delete_all

    has_many :questions, Plunger.Questions.Question, on_delete: :delete_all
    has_many :question_votes, Plunger.Questions.QuestionVote, on_delete: :delete_all
    has_many :question_views, Plunger.Questions.QuestionView, on_delete: :delete_all

    has_many :comments, Plunger.Comments.Comment, on_delete: :delete_all
    has_many :comment_votes, Plunger.Comments.CommentVote, on_delete: :delete_all


    timestamps()
  end

  @required_fields ~w(name email)
  @optional_fields ~w()

  @required_file_fields ~w()
  @optional_file_fields ~w(avatar)

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ coherence_fields)
    |> validate_required([:email])
    |> cast_attachments(attrs, @optional_file_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_coherence_assent(attrs)
    |> unique_constraint(:email)
    #|> unique_constraint(:username)
  end

  def changeset(%User{} = user, attrs, :password) do
    user
    |> cast(attrs, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(attrs)
    #|> changeset(attrs)
    #|> cast(attrs, [:password])
    #|> validate_length(:password, min: 6, max: 100)
    #|> put_pass_hash()
  end

  #defp put_pass_hash(changeset) do
  #  case changeset do
  #    %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
  #      put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
  #    _ ->
  #      changeset
  #  end
  #end
end
