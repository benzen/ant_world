defmodule AntWorld.Ant do

  def start_link(world_pid) do
    w_state = GenServer.call world_pid, :state
    ctx = %{world: world_pid, dimension: w_state.dimension, anthill: w_state.anthill, position: w_state.anthill, bag: []}
    spawn_link( fn -> loop ctx end)
  end

  defp loop(ctx) do
    receive do
      :food  -> AntWorld.Ant.go_home_with_one ctx
      :grass -> AntWorld.Ant.snort_else_where ctx
      :ok    -> AntWorld.Ant.go_home ctx
      {:status, cb}->
        cb.( nil, ctx.position)
        loop(ctx)
      end
  end

  def snort_else_where(ctx) do
    np = next_pos(ctx)
    GenServer.cast ctx.world, {:snort, np, self}
    nctx = Dict.put ctx, :position, np
    loop(nctx)
  end

  def go_home_with_one(ctx) do
    go_home Dict.put( ctx, :bag, [1|ctx.bag])
  end

  def go_home(ctx) do
    np = next_pos_to_home ctx
    cond do
      np == ctx.anthill ->
        IO.puts "Home sweet home #{inspect(self)}"
        exit(:normal)
      true ->
        GenServer.cast ctx.world, {:path, np, self}
        nctx = Dict.put ctx, :position, np
        loop(nctx)
    end
  end

  def moves({x,y}) do
    [ { x+1,y   },
      { x  ,y+1 },
      { x-1,y   },
      { x  ,y-1 }]
  end

  def next_pos( ctx ) do
    :random.seed(:os.timestamp)
    moves(ctx.position)
    |> Enum.filter( &( is_in_bound(ctx.dimension, &1)))
    |> Enum.shuffle()
    |> List.first()
  end

  def next_pos_to_home(ctx) do
    {tx, ty} = ctx.anthill
    moves(ctx.position)
    |> Enum.filter( &(is_in_bound(ctx.dimension, &1)))
    |> Enum.sort_by( &(distance( {tx,ty}, &1)) )
    |> List.first
  end

  def distance({xa,ya}, {xb,yb})do
     x = :math.pow(xb-xa, 2)
     y = :math.pow(yb-ya, 2)
     :math.sqrt(x+y)
  end

  def is_in_bound({width, height}, {x, y}) do
    x >= 0     and
    y >= 0     and
    x < width  and
    y < height
  end

end
