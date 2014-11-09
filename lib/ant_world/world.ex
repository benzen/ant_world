defmodule Ant_world.World do

  use GenServer

  @home {0,0}

#   ###Public API
#   def start_link(food_position) do
#     GenServer.start_link(__MODULE__, food_position, name: __MODULE__)
#   end
#
#   def walk(position, nb_food_carried) do
#     GenServer.call __MODULE__, {:walk, position, nb_food_carried}
#   end
#
#   def snort(position, nb_food_carried) do
#     GenServer.call __MODULE__, {:snort, position, nb_food_carried}
#   end
#
# ### Private API

  def init( food_position ) do
    IO.puts "que le monde soit #{inspect(food_position)}"
    {:ok, food_position}
  end

  def handle_call({:walk, {x,y}, 1}, _sender, food_position) when {x,y} == @home do
     IO.puts "Rest In Peace" # no call to loop
     {:noreply, food_position}
  end

  def handle_call({:walk, {x,y}, _}, _sender, food_position) do
      IO.puts "WORLD: walked"
      {:reply, {:ok, {x,y}}, food_position}
  end

  def handle_call({:snort, {x,y}, 0}, _sender, food_position) when {x,y} == @home do
    IO.puts "Got home but will continue to search"
    {:reply, {:smell, {x,y}, :grass}, food_position}
  end

  def handle_call({:snort, {x,y}, _count_in_bag}, _sender, food_position) do
    IO.puts "WORLD: snorted #{x},#{y}"
    if Enum.member? food_position, {x,y} do
        IO.puts "WORLD: is on foods"
        {:reply, {:smell, {x,y}, :food, 1}, List.delete( food_position, {x,y} ) }
    else
        IO.puts "WORLD: is on Grass"
        {:reply, {:smell, {x,y}, :grass}, food_position }
    end
  end
end
