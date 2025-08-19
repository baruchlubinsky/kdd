defmodule Kdd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      KddWeb.Telemetry,
      # Start the Ecto repository
      Kdd.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Kdd.PubSub},
      # Start the Endpoint (http/https)
      KddWeb.Endpoint,
      # Start a worker by calling: Kdd.Worker.start_link(arg)
      # {Kdd.Worker, arg}
      {Cachex, [:kdd]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kdd.Supervisor]
    return = Supervisor.start_link(children, opts)

    cms_db = Application.fetch_env!(:kdd, :cms_db)
    token = Application.fetch_env!(:kdd_notion_ex, :cms_key)
    KddNotionEx.CMS.Config.validate_notion_db!(KddNotionEx.Client.new(token), cms_db)

    return
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KddWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
