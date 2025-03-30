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

  # Rutas públicas sin autenticación requerida
  scope "/", TalentWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/install", PwaController, :install

    # Rutas de cierre de sesión
    delete "/users/log_out", UserSessionController, :delete
    get "/users/log_out", UserSessionController, :delete
  end

  # Rutas para usuarios no autenticados
  scope "/", TalentWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    # Una sola live_session para todas las rutas de usuarios no autenticados
    live_session :unauthenticated_user,
      on_mount: [{TalentWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  # Todas las rutas que requieren autenticación (independientemente del rol)
  # usando una sola live_session para evitar recargas innecesarias
  scope "/", TalentWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated_user,
      on_mount: [{TalentWeb.UserAuth, :ensure_authenticated}] do

      # Rutas comunes para todos los usuarios autenticados
      live "/dashboard", DashboardLive, :index
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      # Rutas para administradores - protegidas por verificación interna en los LiveViews
      scope "/admin", as: :admin do
        # Usuario
        live "/users", UserLive.Index, :index
        live "/users/new", UserLive.Index, :new
        live "/users/:id/edit", UserLive.Index, :edit
        live "/users/:id", UserLive.Show, :show

        # Categorías
        live "/categories", CategoryLive.Index, :index
        live "/categories/new", CategoryLive.Index, :new
        live "/categories/:id/edit", CategoryLive.Index, :edit
        live "/categories/:id", CategoryLive.Show, :show

        # Criterios
        live "/scoring_criteria", ScoringCriterionLive.Index, :index
        live "/scoring_criteria/new", ScoringCriterionLive.Index, :new
        live "/scoring_criteria/:id/edit", ScoringCriterionLive.Index, :edit
        live "/scoring_criteria/:id", ScoringCriterionLive.Show, :show

        # Jueces
        live "/judges", JudgeLive.Index, :index
        live "/judges/new", JudgeLive.Index, :new
        live "/judges/:id/edit", JudgeLive.Index, :edit
        live "/judges/:id", JudgeLive.Show, :show
        live "/judges/:id/assign_categories", JudgeLive.AssignCategories, :edit
        live "/category_judges", CategoryJudgeLive.Index, :index

        # Gestión de redes sociales
        live "/networks", NetworkLive.Index, :index
        live "/networks/new", NetworkLive.Index, :new
        live "/networks/:id/edit", NetworkLive.Index, :edit
        live "/networks/:id", NetworkLive.Show, :show

        # Gestión de personas
        live "/people", PersonLive.Index, :index
        live "/people/new", PersonLive.Index, :new
        live "/people/:id/edit", PersonLive.Index, :edit
        live "/people/:id", PersonLive.Show, :show
      end

      # Rutas para secretarios
      scope "/secretary", as: :secretary do
        live "/participants", ParticipantLive.Index, :index
        live "/participants/new", ParticipantLive.Index, :new
        live "/participants/:id/edit", ParticipantLive.Index, :edit
        live "/participants/:id", ParticipantLive.Show, :show
      end

      # Rutas para jurados
      scope "/jury", as: :jury do
        live "/scoring", ScoringLive.Index, :index
        live "/scoring/:participant_id", ScoringLive.Show, :show
      end

      # Rutas para escribanas
      scope "/notary", as: :notary do
        live "/results", ResultsLive.Index, :index
        live "/results/:category_id", ResultsLive.Show, :show
      end
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:talent, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TalentWeb.Telemetry
    end
  end
end
