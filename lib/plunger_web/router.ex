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
    resources "/users", UserController, except: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/categories", CategoryController, only: [:index, :new, :create, :show]

    get "/questions/:id/upvote", QuestionController, :upvote
    get "/questions/:id/downvote", QuestionController, :downvote
    resources "/questions", QuestionController
    post "/questions", QuestionController, :index

    get "/responses/:id/upvote", ResponseController, :upvote
    get "/responses/:id/downvote", ResponseController, :downvote
    resources "/responses", ResponseController, only: [:create]

    get "/comments/:id/upvote", CommentController, :upvote
    get "/comments/:id/downvote", CommentController, :downvote
    resources "/comments", CommentController, only: [:create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlungerWeb do
  #   pipe_through :api
  # end
end
