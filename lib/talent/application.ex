defmodule Talent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TalentWeb.Telemetry,
      Talent.Repo,
      {DNSCluster, query: Application.get_env(:talent, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Talent.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Talent.Finch},
      # Start a worker by calling: Talent.Worker.start_link(arg)
      # {Talent.Worker, arg},
      # Start to serve requests, typically the last entry
      TalentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Talent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TalentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
