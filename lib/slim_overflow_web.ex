defmodule SlimOverflowWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SlimOverflowWeb, :controller
      use SlimOverflowWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SlimOverflowWeb
    #  use Guardian.Phoenix.Controller
    #  alias Guardian.Plug.EnsureAuthenticated
    #  alias Guardian.Plug.EnsurePermissions
      alias SlimOverflow.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
      import Plug.Conn
      import SlimOverflowWeb.Router.Helpers
      import SlimOverflowWeb.Gettext
      #import SlimOverflowWeb.Auth, only: [authenticate_user: 2]
      import SlimOverflow.Categories, only: [load_categories: 2]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/slim_overflow_web/templates",
                        namespace: SlimOverflowWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, get_csrf_token: 0, get_flash: 1, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SlimOverflowWeb.Router.Helpers
      import SlimOverflowWeb.ErrorHelpers
      import SlimOverflowWeb.Gettext
      import SlimOverflowWeb.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller

      import SlimOverflowWeb.Auth, only: [put_user_token: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SlimOverflowWeb.Gettext
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
