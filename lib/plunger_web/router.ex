defmodule PlungerWeb.Router do
  use PlungerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    #plug PlungerWeb.Auth, repo: Plunger.Repo
    plug NavigationHistory.Tracker
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end


  scope "/", PlungerWeb do
    pipe_through [:browser, :browser_auth] # Use the default browser stack

    get "/", PageController, :index

    delete "/logout", AuthController, :logout
    get "/credentials", AuthController, :credentials
    get "/verify", AuthController, :verify_email

    get "/signup", SignupController, :new
    resources "/users", UserController, except: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/categories", CategoryController, only: [:index, :new, :create, :show]

    get "/questions/:id/upvote", QuestionController, :upvote
    get "/questions/:id/downvote", QuestionController, :downvote
    resources "/questions", QuestionController
    post "/questions", QuestionController, :index

    get "/responses/:id/upvote", ResponseController, :upvote
    get "/responses/:id/downvote", ResponseController, :downvote
    get "/responses/:id/promote", ResponseController, :promote
    resources "/responses", ResponseController, only: [:create]

    get "/comments/:id/upvote", CommentController, :upvote
    get "/comments/:id/downvote", CommentController, :downvote
    resources "/comments", CommentController, only: [:create]
  end

  scope "/auth", PlungerWeb do
    pipe_through [:browser, :browser_auth]

    get "/:identity", AuthController, :login
    get "/:identity/callback", AuthController, :callback
    post "/:identity/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlungerWeb do
  #   pipe_through :api
  # end
end
