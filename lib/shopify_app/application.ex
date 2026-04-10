defmodule ShopifyApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShopifyAppWeb.Telemetry,
      ShopifyApp.Repo,
      {DNSCluster, query: Application.get_env(:shopify_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ShopifyApp.PubSub},
      # Start a worker by calling: ShopifyApp.Worker.start_link(arg)
      # {ShopifyApp.Worker, arg},
      # Start to serve requests, typically the last entry
      ShopifyAppWeb.Endpoint,
      ShopifyAPI.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShopifyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShopifyAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
