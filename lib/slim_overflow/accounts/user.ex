defmodule SlimOverflow.Accounts.User do
  use Ecto.Schema
  use Coherence.Schema
  use CoherenceAssent.Schema
  use Arc.Ecto.Schema
  alias SlimOverflowWeb.Avatar
  import Ecto.Changeset
  alias SlimOverflow.Accounts.User

  schema "users" do
    field :avatar, SlimOverflowWeb.Avatar.Type
    field :email, :string
    field :name, :string
    field :reputation, :integer, default: 0
    field :position, :string
    field :description, :string
    field :is_admin, :boolean, default: false
    coherence_schema()
    coherence_assent_schema()

    many_to_many :categories, SlimOverflow.Categories.Category, join_through: "categories_users", on_delete: :delete_all, on_replace: :delete

    has_many :responses, SlimOverflow.Responses.Response, on_delete: :delete_all
    has_many :response_votes, SlimOverflow.Responses.ResponseVote, on_delete: :delete_all

    has_many :questions, SlimOverflow.Questions.Question, on_delete: :delete_all
    has_many :question_votes, SlimOverflow.Questions.QuestionVote, on_delete: :delete_all
    has_many :question_views, SlimOverflow.Questions.QuestionView, on_delete: :delete_all
    has_many :category_views, SlimOverflow.Categories.CategoryView, on_delete: :delete_all
    has_many :category_reputations, SlimOverflow.Accounts.CategoryReputation, on_delete: :delete_all

    has_many :profile_views_received, SlimOverflow.Accounts.ProfileView, foreign_key: :viewed_user_id, on_delete: :delete_all
    has_many :profiles_viewed, SlimOverflow.Accounts.ProfileView, foreign_key: :viewing_user_id, on_delete: :delete_all
    has_many :comments, SlimOverflow.Comments.Comment, on_delete: :delete_all
    has_many :comment_votes, SlimOverflow.Comments.CommentVote, on_delete: :delete_all


    timestamps()
  end

  @required_fields ~w(name email position description)
  @optional_fields ~w(is_admin)

  @required_file_fields ~w()
  @optional_file_fields ~w(avatar)

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ coherence_fields, @optional_fields)
    |> cast_attachments(attrs, @optional_file_fields)
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> validate_coherence_assent(attrs)
    |> unique_constraint(:email)
    |> put_default_profile_image()
    #|> unique_constraint(:username)
  end

  def changeset(%User{} = user, attrs, :password) do
    user
    |> cast(attrs, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(attrs)
  end

  defp put_default_profile_image(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, data: %{avatar: nil, email: email}} ->
        put_change(changeset, :avatar, %{file_name: "no_profile_image.gif", updated_at: Ecto.DateTime.utc})
      _ -> changeset
    end
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
