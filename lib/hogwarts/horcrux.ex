defmodule Hogwarts.Horcrux do
  @moduledoc """
  Evil stuff, yo!
  """
  use GenServer

  alias Hogwarts.Wizard

  require Logger

  def destroy(name) do
    %{belongs_to: wizard} = info(name)
    Wizard.rm_horcrux(wizard, name)
    GenServer.stop(name)
  end

  def new(name, wizard) when is_atom(name) do
    GenServer.start_link(__MODULE__, %{name: name, belongs_to: wizard, soul_points: 0}, name: name)

    # case Wizard.is?(wizard) do
    #   true ->
    #     GenServer.start_link(__MODULE__, %{name: name, belongs_to: wizard, soul_points: 0},
    #       name: name
    #     )

    #   false ->
    #     {:error, "The named is not a wizard"}
    # end
  end

  def info(name) do
    GenServer.call(name, :info)
  end

  def update_soul_points(name, soul_points) do
    GenServer.call(name, {:update_soul_points, soul_points})
  end

  @doc """
  Is this thing a horcrux?
  """
  def is?(name) do
    Pockets.has_key?(:horcruxes, name)
  end

  ##############################################################################
  @impl true
  def init(%{name: horcrux_name, belongs_to: _} = state) do
    Pockets.put(:horcruxes, horcrux_name, self())
    {:ok, state}
  end

  @impl true
  def handle_call(:info, _, state) do
    {:reply, state, state}
  end

  def handle_call({:update_soul_points, soul_points}, _, state) do
    {:reply, :ok, %{state | soul_points: soul_points}}
  end
end
