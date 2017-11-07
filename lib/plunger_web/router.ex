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
    #plug PlungerWeb.Auth, repo: Plunger.Repo
    plug Coherence.Authentication.Session
    plug NavigationHistory.Tracker
    #plug :put_user_token
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

  #pipeline :browser_auth do
  #  plug Guardian.Plug.VerifySession
  #  plug Guardian.Plug.LoadResource
  #  plug :put_user_token
  #end

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

    #delete "/logout", AuthController, :logout
    #get "/credentials", AuthController, :credentials
    #get "/verify", AuthController, :verify_email
    #get "/signup", SignupController, :new
  end

  scope "/", PlungerWeb do
    pipe_through :protected

    resources "/users", UserController, except: [:delete, :new, :create]
    get "/users/:id/edit_email", UserController, :edit_email
    post "/users/:id/update_email", UserController, :update_email
    put "/users/:id/update_categories", UserController, :update_categories
    get "/users/:id/promote", UserController, :promote
    put "/lock/:id", UserController, :lock
    put "/unlock/:id", UserController, :unlock
    put "/confirm/:id", UserController, :confirm

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

  # Other scopes may use custom stacks.
  # scope "/api", PlungerWeb do
  #   pipe_through :api
  # end

end
