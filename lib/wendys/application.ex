defmodule Wendys.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WendysWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:wendys, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Wendys.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Wendys.Finch},
      # Start a worker by calling: Wendys.Worker.start_link(arg)
      # {Wendys.Worker, arg},
      # Start to serve requests, typically the last entry
      WendysWeb.Endpoint,
      {Wendys.Transcription.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wendys.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WendysWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
