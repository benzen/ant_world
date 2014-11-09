defmodule Ant_world.Ant do
  @home {0,0}

  def init( world_pid ,bag\\[]) do
    IO.puts "ANT: I'm alive"
    snort_else_where({0,0}, {world_pid, bag})
  end

  # def loop({world_pid, bag}, resp) do
  #   receive do
  #     {:smell, {x,y}, :grass}           -> snort_else_where({x,y}, {world_pid, bag})
  #     {:smell, {x,y}, :food, _quantity} -> go_home_with_one({x,y}, {world_pid, bag})
  #     {:ok, {x,y} }                     -> go_home {x,y}, {world_pid, bag}
  #   end
  # end

  def loop({world_pid, bag}, {:smell, {x,y}, :grass}) do
    snort_else_where({x,y}, {world_pid, bag})
  end
  def loop({world_pid, bag},  {:smell, {x,y}, :food, _quantity})   do
    go_home_with_one({x,y}, {world_pid, bag})
  end
  def loop({world_pid, bag}, {:ok, {x,y} } ) do
    go_home {x,y}, {world_pid, bag}
  end

  def snort_else_where({x,y}, {world_pid, bag}) do
    IO.puts "snorting else where"
    resp = GenServer.call world_pid, {:snort, next_pos({x,y}), Enum.count(bag)}
    loop {world_pid, bag}, resp
  end
  def go_home_with_one({x,y}, {world_pid, bag}) do
    IO.puts "go home with something"
    new_bag = [ 1 | bag]
    go_home {x,y}, {world_pid, new_bag}
  end
  def go_home({x,y}, {world_pid, bag}) do
    IO.puts "go home"
    resp = GenServer.call world_pid, {:walk, next_pos_to_home({x,y}), Enum.count(bag)}
    loop {world_pid,bag}, resp
  end


  def moves({x,y}) do
    [ { x+1,y   },
      { x  ,y+1 },
      { x-1,y   },
      { x  ,y-1 }]
  end

  def next_pos( {x,y} ) do
    moves({x,y})
    |> Enum.filter( &( is_in_bound(&1)))
    |> Enum.shuffle()
    |> List.first
  end

  def next_pos_to_home( {x, y}  ) do
    {tx, ty} = @home
    moves({x,y})
    |> Enum.filter( &(is_in_bound(&1)))
    |> Enum.sort_by( &(distance( {tx,ty}, &1)) )
    |> List.first
  end

  def distance({xa,ya}, {xb,yb})do
     x = :math.pow(xb-xa, 2)
     y = :math.pow(yb-ya, 2)
     :math.sqrt(x+y)
  end

  def is_in_bound({x, y}) do
    x >= 0 and
    y >= 0 and
    x < 1000 and
    y < 1000
  end

end
