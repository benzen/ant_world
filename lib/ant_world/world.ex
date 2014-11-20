defmodule AntWorld.World do

  use GenServer

  def start_link(_width, _height, food_position) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{food_position: food_position, path_position: []} )
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

  def handle_call(:state, _sender, ctx) do
    resp = %{
      dimension: get_dimension(),
      food: ctx.food_position,
      path: ctx.path_position,
      anthill: anthill()
    }
    {:reply, resp, ctx}
  end

  def handle_cast({:path, {x,y}, sender}, ctx) do
      send sender, :ok
      {:noreply ,Dict.put( ctx, :path_position, [{x,y}|ctx.path_position])}
  end

  def handle_cast({:snort, {x,y}, sender}, ctx) do
    if Enum.member? ctx.food_position, {x,y} do
        send sender, :food
        n_food_position = List.delete(ctx.food_position, {x,y})
        n_ctx = Map.put( ctx, :path_position, n_food_position)
        {:noreply, n_ctx }
    else
        send sender, :grass
        {:noreply, ctx }
    end
  end

  def handle_cast(_,ctx)do
    IO.puts "Unhandeled messges"
    {:noreply,ctx}
  end

end
