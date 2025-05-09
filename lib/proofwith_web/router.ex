defmodule ProofwithWeb.Router do
  use ProofwithWeb, :router

  import ProofwithWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ProofwithWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Marketing routes
  scope "/", ProofwithWeb, host: ["localhost"] do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Auth routes
  scope "/", ProofwithWeb, host: ["app.localhost"] do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{ProofwithWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  scope "/", ProofwithWeb, host: ["app.localhost"] do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ProofwithWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:proofwith, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev", host: ["app.localhost"] do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ProofwithWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Application routes
  scope "/", ProofwithWeb, host: ["app.localhost"] do
    pipe_through [:browser, :require_authenticated_user]

    live_session :user_authenticated,
      on_mount: [{ProofwithWeb.UserAuth, :require_authenticated}] do
      live "/", ApplicationLive.Organizations.Organization
    end

    scope "/:org_slug" do
      live_session :org_authenticated,
        on_mount: [
          {ProofwithWeb.UserAuth, :require_authenticated},
          {ProofwithWeb.Scopes, :require_org_scope}
        ] do
        live "/", ApplicationLive.Organization.Projects
        live "/settings", ApplicationLive.Organization.Settings
        live "/billing", ApplicationLive.Organization.Billing
        live "/team", ApplicationLive.Organization.Team
      end
    end

    scope "/:org_slug/:project_slug" do
      live_session :project_authenticated,
        on_mount: [
          {ProofwithWeb.UserAuth, :require_authenticated},
          {ProofwithWeb.Scopes, :require_org_scope},
          {ProofwithWeb.Scopes, :require_project_scope}
        ] do
        live "/", ApplicationLive.Project
        live "/settings", ApplicationLive.Project.Settings
      end
    end
  end
end
