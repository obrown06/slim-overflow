defmodule PlungerWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use PlungerWeb, :controller
      use PlungerWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: PlungerWeb
    #  use Guardian.Phoenix.Controller
    #  alias Guardian.Plug.EnsureAuthenticated
    #  alias Guardian.Plug.EnsurePermissions
      alias Plunger.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
      import Plug.Conn
      import PlungerWeb.Router.Helpers
      import PlungerWeb.Gettext
      import PlungerWeb.Auth, only: [authenticate_user: 2]
      import Plunger.Categories, only: [load_categories: 2]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/plunger_web/templates",
                        namespace: PlungerWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, get_csrf_token: 0, get_flash: 1, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import PlungerWeb.Router.Helpers
      import PlungerWeb.ErrorHelpers
      import PlungerWeb.Gettext
      import PlungerWeb.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller

      #import PlungerWeb.AuthHelpers, only: [put_user_token: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import PlungerWeb.Gettext
      import Ecto.Query
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
