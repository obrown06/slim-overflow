Code.ensure_loaded Phoenix.Swoosh

defmodule SlimOverflowWeb.UserEmail do
  @moduledoc false
  use Phoenix.Swoosh, view: SlimOverflowWeb.EmailView, layout: {SlimOverflowWeb.LayoutView, :email}
  alias Swoosh.Email
  require Logger
  alias Coherence.Config
  import SlimOverflowWeb.Gettext
  alias SlimOverflow.Questions.Question
  alias SlimOverflow.Repo
  alias SlimOverflowWeb.UserEmail
  use Swoosh.Mailer, otp_app: :slim_overflow
  use Phoenix.Router

  def email_interested_users(conn, %Question{} = question) do
    question = Repo.preload(question, :categories)
    for category <- question.categories do
      category = Repo.preload(category, :users)
      for user <- category.users do
        UserEmail.question_posted(user, SlimOverflowWeb.Router.Helpers.question_url(conn, :show, question), category) |> SlimOverflowWeb.Mailer.deliver
      end
    end
  end

  defp site_name, do: Config.site_name(inspect Config.module)

  def question_posted(user, url, category) do
    %Email{}
    |> from(from_email())
    |> to(user_email(user))
    |> subject(dgettext("coherence", "%{site_name} - New Question Posted in Your Flagged Category", site_name: site_name()))
    |> render_body("new_question.html", %{url: url, name: first_name(user.name), category: category.name})
  end

  defp user_email(user) do
    {user.name, user.email}
  end

  defp first_name(name) do
    case String.split(name, " ") do
      [first_name | _] -> first_name
      _ -> name
    end
  end

  defp from_email do
    case Coherence.Config.email_from do
      nil ->
        Logger.error ~s|Need to configure :coherence, :email_from_name, "Name", and :email_from_email, "me@example.com"|
        nil
      {name, email} = email_tuple ->
        if is_nil(name) or is_nil(email) do
          Logger.error ~s|Need to configure :coherence, :email_from_name, "Name", and :email_from_email, "me@example.com"|
          nil
        else
          email_tuple
        end
    end
  end
end
