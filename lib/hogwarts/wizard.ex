defmodule Hogwarts.Wizard do
  @moduledoc """

  """
  use GenServer

  alias Hogwarts.Horcrux

  require Logger

  def add_horcrux(wizard_name, horcrux_name) do
    GenServer.call(wizard_name, {:add_horcrux, horcrux_name})
  end

  def rm_horcrux(wizard_name, horcrux_name) do
    GenServer.call(wizard_name, {:rm_horcrux, horcrux_name})
  end

  def new(wizard_name) when is_atom(wizard_name) do
    GenServer.start_link(
      __MODULE__,
      %{wizard_name: wizard_name, soul_points: 100, horcruxes: MapSet.new()},
      name: wizard_name
    )
  end

  def info(wizard_name) do
    GenServer.call(wizard_name, :info)
  end

  @doc """
  Is this wizard_name that of a wizard?
  """
  def is?(wizard_name) do
    Pockets.has_key?(:wizards, wizard_name)
  end

  @impl true
  def init(%{wizard_name: wizard_name} = state) do
    Pockets.put(:wizards, wizard_name, self())
    {:ok, state}
  end

  @impl true
  def handle_call(:info, _, state) do
    {:reply, state, state}
  end

  def handle_call(
        {:add_horcrux, horcrux_name},
        _,
        %{wizard_name: wizard_name, soul_points: soul_points, horcruxes: horcruxes} = state
      ) do
    {:ok, _} = Horcrux.new(horcrux_name, wizard_name)
    # Redistribute soul_points
    sum = sum_horcrux_soul_points(horcruxes) + soul_points
    updated_horcruxes = MapSet.put(horcruxes, horcrux_name)
    vessels = 1 + MapSet.size(updated_horcruxes)
    points_per_vessel = sum / vessels

    redistribute_soul_points(updated_horcruxes, points_per_vessel)
    {:reply, :ok, %{state | horcruxes: updated_horcruxes, soul_points: points_per_vessel}}
  end

  def handle_call({:rm_horcrux, horcrux_name}, _, %{horcruxes: horcruxes} = state) do
    {:reply, :ok, %{state | horcruxes: MapSet.delete(horcruxes, horcrux_name)}}
  end

  defp sum_horcrux_soul_points(horcruxes) do
    horcruxes
    |> Enum.reduce(0, fn h, acc ->
      acc + (h |> Horcrux.info() |> Map.fetch!(:soul_points))
    end)
  end

  defp redistribute_soul_points(horcruxes, new_soul_points) do
    horcruxes
    |> Enum.each(fn h ->
      h |> Horcrux.update_soul_points(new_soul_points)
    end)
  end
end
