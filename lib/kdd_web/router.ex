defmodule KddWeb.Router do
  use KddWeb, :router

  import KddWeb.Auth.SessionController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KddWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :get_kdd_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KddWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about", PageController, :about
    get "/notion", PageController, :notion

  end

  scope "/auth", KddWeb.Auth do
    pipe_through :browser

    get "/notion/authenticate", NotionController, :authenticate
  end

  scope "/apps", KddWeb.Apps do
    pipe_through :browser

    get "/budget", BudgetController, :index
    get "/budget/settings", BudgetController, :settings
    post "/budget/configure", BudgetController, :configure
    put "/budget/configure", BudgetController, :configure
    get "/budget/expense", BudgetController, :expense
    post "/budget/expense", BudgetController, :record_expense

  end

  # Other scopes may use custom stacks.
  # scope "/api", KddWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:kdd, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KddWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/token", KddWeb.Auth.SessionController, :dev_token
    end
  end
end
