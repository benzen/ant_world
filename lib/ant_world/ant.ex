defmodule AntWorld.Ant do

  def start_link(worldPid) do
    dimension = AntWorld.World.get_dimension()
    anthill = AntWorld.World.anthill()
    ctx = %{world: worldPid, dimension: dimension, anthill: anthill, position: anthill, bag: [], }
    {:ok, antPid} = Agent.start_link( fn -> ctx end)
    IO.puts "Inside ant launcher #{inspect(self)}"
    Agent.update( antPid, &( snort_else_where(&1, anthill) ))

    antPid
  end

  def loop do
    receive do
      {:meat}  -> AntWorld.Ant.go_home_with_one Agent.get self, &(&1.position)
      {:grass} -> AntWorld.Ant.snort_else_where Agent.get self, &(&1.position)
      {:ok}    -> AntWorld.Ant.go_home Agent.get self, &(&1.position)
      end
  end
  #
  # def loop(ctx, {:smell, {x,y}, :grass}) do
  #   snort_else_where({x,y}, ctx)
  # end
  # def loop(ctx,  {:smell, {x,y}, :food, _quantity})   do
  #   go_home_with_one({x,y}, ctx)
  # end
  # def loop(ctx, {:ok, {x,y} } ) do
  #   go_home {x,y}, ctx
  # end

  def snort_else_where(ctx, {x,y}) do
    np = next_pos(ctx, {x,y})
    IO.puts "snort else where #{inspect(ctx.world)}"
    IO.puts "ant #{inspect(self)}"
    GenServer.cast ctx.world, {:snort, np, self}
    Dict.put ctx, :position, np
    loop()
  end

  def go_home_with_one(ctx, {x,y}) do
    n_ctx = Dict.put ctx, :bag, [1|ctx.bag]
    go_home n_ctx, {x,y}
  end
  def go_home(ctx, {x,y}) do
    np = next_pos_to_home ctx, {x,y}
    GenServer.cast ctx.world, {:walk, np, self}
    Dict.put ctx, :position, np
    loop()
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
