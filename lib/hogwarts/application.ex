defmodule Hogwarts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _} = Pockets.new(:wizards)
    {:ok, _} = Pockets.new(:horcruxes)

    children = [
      # Starts a worker by calling: Hogwarts.Worker.start_link(arg)
      # {Hogwarts.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hogwarts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
