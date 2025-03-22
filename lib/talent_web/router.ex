defmodule TalentWeb.Router do
  use TalentWeb, :router

  import TalentWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TalentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TalentWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", TalentWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/dashboard", DashboardLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TalentWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:talent, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TalentWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TalentWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TalentWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TalentWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TalentWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TalentWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TalentWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", TalentWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_role]

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit
    live "/users/:id", UserLive.Show, :show

    live "/categories", CategoryLive.Index, :index
    live "/categories/new", CategoryLive.Index, :new
    live "/categories/:id/edit", CategoryLive.Index, :edit
    live "/categories/:id", CategoryLive.Show, :show

    live "/judges", JudgeLive.Index, :index
    live "/judges/new", JudgeLive.Index, :new
    live "/judges/:id/edit", JudgeLive.Index, :edit
    live "/judges/:id", JudgeLive.Show, :show

    live "/scoring_criteria", ScoringCriterionLive.Index, :index
    live "/scoring_criteria/new", ScoringCriterionLive.Index, :new
    live "/scoring_criteria/:id/edit", ScoringCriterionLive.Index, :edit
    live "/scoring_criteria/:id", ScoringCriterionLive.Show, :show

    live "/judges/:id/assign_categories", JudgeLive.AssignCategories, :edit
    live "/category_judges", CategoryJudgeLive.Index, :index
  end

  # Rutas para secretarios
  scope "/secretary", TalentWeb do
    pipe_through [:browser, :require_authenticated_user, :require_secretary_role]

    live "/participants", ParticipantLive.Index, :index
    live "/participants/new", ParticipantLive.Index, :new
    live "/participants/:id/edit", ParticipantLive.Index, :edit
    live "/participants/:id", ParticipantLive.Show, :show
  end

  # Rutas para jurados
  scope "/jury", TalentWeb do
    pipe_through [:browser, :require_authenticated_user, :require_jury_role]

    live "/scoring", ScoringLive.Index, :index
    live "/scoring/:participant_id", ScoringLive.Show, :show
  end

  # Rutas para escribanas
  scope "/notary", TalentWeb do
    pipe_through [:browser, :require_authenticated_user, :require_notary_role]

    live "/results", ResultsLive.Index, :index
    live "/results/:category_id", ResultsLive.Show, :show
  end
end
