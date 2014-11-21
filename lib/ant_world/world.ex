defmodule AntWorld.World do

  use GenServer

  def start_link(width, height, food_position) do
    ctx = %{
      food_position: food_position,
      path_position: [],
      anthill: {0, 0},
      dimension: {width, height}
    }
    {:ok, pid} = GenServer.start_link(__MODULE__, ctx )
    pid
  end

  def handle_call(:state, _sender, ctx) do
    {:reply, ctx, ctx}
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
    IO.puts "Unhandeled messages"
    {:noreply,ctx}
  end

end
