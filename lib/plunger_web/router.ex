defmodule PlungerWeb.Router do
  use PlungerWeb, :router
  use Coherence.Router
  use CoherenceAssent.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
    plug NavigationHistory.Tracker
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true  # Add this
    plug NavigationHistory.Tracker
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
    coherence_assent_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end


  scope "/", PlungerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", PlungerWeb do
    pipe_through :protected

    resources "/users", UserController, only: [:index, :show, :edit, :update]
    post "/users/:id/update_email", UserController, :update_email
    post "/users/:id/update_password", UserController, :update_password
    put "/users/:id/update_categories", UserController, :update_categories
    get "/users/:id/promote", UserController, :promote

    resources "/categories", CategoryController, only: [:index, :new, :create, :show]

    get "/questions/:id/upvote", QuestionController, :upvote
    get "/questions/:id/downvote", QuestionController, :downvote
    resources "/questions", QuestionController
    #post "/questions", QuestionController, :index

    get "/responses/:id/upvote", ResponseController, :upvote
    get "/responses/:id/downvote", ResponseController, :downvote
    get "/responses/:id/promote", ResponseController, :promote
    post "/responses", ResponseController, :create

    get "/comments/:id/upvote", CommentController, :upvote
    get "/comments/:id/downvote", CommentController, :downvote
    post "/comments", CommentController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlungerWeb do
  #   pipe_through :api
  # end

end
