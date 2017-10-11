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
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/categories", CategoryController, only: [:index, :new, :create, :show]

    resources "/questions", QuestionController
    resources "/questions", QuestionController do
      get "/upvote", QuestionController, :upvote
      get "/downvote", QuestionController, :downvote
      resources "/responses", ResponseController
      resources "/comments", CommentController
    end

    resources "/responses", ResponseController do
      get "/upvote", ResponseController, :upvote
      get "/downvote", ResponseController, :downvote
      resources "/comments", CommentController
    end

    resources "/comments", CommentController do
      get "/upvote", CommentController, :upvote
      get "/downvote", CommentController, :downvote
      resources "/comments", CommentController
    end

  end

  # Other scopes may use custom stacks.
  # scope "/api", PlungerWeb do
  #   pipe_through :api
  # end
end
