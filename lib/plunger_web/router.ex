defmodule PlungerWeb.Router do
  use PlungerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PlungerWeb.Auth, repo: Plunger.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlungerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlungerWeb do
  #   pipe_through :api
  # end
end
