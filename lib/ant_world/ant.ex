defmodule AntWorld.Ant do

  def start_link(worldPid) do
    dimension = AntWorld.World.get_dimension()
    anthill = AntWorld.World.anthill()
    ctx = %{world: worldPid, dimension: dimension, anthill: anthill, position: anthill, bag: []}
    spawn_link( fn -> loop ctx end)
  end

  defp loop(ctx) do
    position =  ctx.position
    receive do
      :meat  -> AntWorld.Ant.go_home_with_one ctx, position
      :grass -> AntWorld.Ant.snort_else_where ctx, position
      :ok    -> AntWorld.Ant.go_home ctx, position
      {:status, cb}->
        cb.( nil, position)
        loop(ctx)
      end
  end

  def snort_else_where(ctx, {x,y}) do
    np = next_pos(ctx, {x,y})
    GenServer.cast ctx.world, {:snort, np, self}
    nctx = Dict.put ctx, :position, np
    loop(nctx)
  end

  def go_home_with_one(ctx, {x,y}) do
    IO.puts "FOOOOOOOD"
    n_ctx = Dict.put ctx, :bag, [1|ctx.bag]
    go_home n_ctx, {x,y}
  end
  def go_home(ctx, {x,y}) do
    np = next_pos_to_home ctx, {x,y}
    GenServer.cast ctx.world, {:walk, np, self}
    nctx = Dict.put ctx, :position, np
    loop(nctx)
  end


  def moves({x,y}) do
    [ { x+1,y   },
      { x  ,y+1 },
      { x-1,y   },
      { x  ,y-1 }]
  end

  def next_pos( ctx, {x,y} ) do
    moves({x,y})
    |> Enum.filter( &( is_in_bound(ctx, &1)))
    |> Enum.shuffle()
    |> List.first
  end

  def next_pos_to_home( ctx, {x, y}) do
    {tx, ty} = ctx.anthill
    moves({x,y})
    |> Enum.filter( &(is_in_bound(ctx, &1)))
    |> Enum.sort_by( &(distance( {tx,ty}, &1)) )
    |> List.first
  end

  def distance({xa,ya}, {xb,yb})do
     x = :math.pow(xb-xa, 2)
     y = :math.pow(yb-ya, 2)
     :math.sqrt(x+y)
  end

  def is_in_bound(ctx, {x, y}) do
    {width, height} = ctx.dimension
    x >= 0 and
    y >= 0 and
    x < width and
    y < height
  end

end
