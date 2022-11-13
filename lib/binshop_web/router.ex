defmodule BinshopWeb.Router do
  use BinshopWeb, :router
  @dialyzer :no_match

  use BinshopWeb.Admin.Router
  use BinshopWeb.Web.Router

  import BinshopWeb.Auth.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user

    # Remove and introduce  layouts per nested context
    plug :put_root_layout, {BinshopWeb.Web.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BinshopWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BinshopWeb.Telemetry
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end
  end

  ## Authentication routes

  scope "/", BinshopWeb.Auth do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :request
    get "/users/register-pending", UserRegistrationController, :pending
    get "/users/register/:token", UserRegistrationController, :confirm
    post "/users/register/:token", UserRegistrationController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", BinshopWeb.Auth do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    get "/users/register-complete", UserRegistrationController, :created
  end

  scope "/", BinshopWeb.Auth do
    pipe_through [:browser]

    delete "/users/log_out", AuthController, :delete
  end

  scope "/auth", BinshopWeb.Auth do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :identity_callback
    get "/", AuthController, :request
  end

  AdminRoutes.routes()
  WebRoutes.routes()
end
