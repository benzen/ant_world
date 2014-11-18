defmodule AntWorld.World do

  use GenServer

  def start_link(_width, _height, food_position) do
    {:ok, pid} = GenServer.start_link(__MODULE__, food_position )
    pid
  end

  # def get_state() do
  #   GenServer.call(__MODULE__, :state)
  # end

  def get_dimension() do
    {1000, 1000}
  end

  def anthill() do #same as @home
    {0,0}
  end

  def handle_call(:state, _sender, food_position) do
    resp = %{
      dimension: get_dimension(),
      food: food_position,
      anthill: anthill()
    }
    {:reply, resp, food_position}
  end

  def handle_cast({:walk, {_x,_y}, sender}, food_position) do
      send sender, :ok
      {:noreply ,food_position}
  end

  def handle_cast({:snort, {x,y}, sender}, food_position) do
    if Enum.member? food_position, {x,y} do
        send sender, :food
        new_food_position = List.delete food_position, {x,y}
        {:noreply, new_food_position }
    else
        send sender, :grass
        {:noreply, food_position }
    end
  end

  def handle_cast(_,ctx)do
    IO.puts "Unhandeled messges"
    {:noreply,ctx}
  end

end
