defmodule Ant do
  @home {0,0}

  def live(bag) do
    receive do
      { sender, :birth, {x,y} } -> # first snorting
        send sender, { self, :snort, next_pos({x,y}), Enum.count(bag) }
        live(bag)

      { sender, :smell, {x,y}, :grass } -> # smell like grass, ain't junky so go on
        {x1,y1} = next_pos({x,y})
        send sender, {self, :snort, {x1,y1}, Enum.count(bag)}
        live(bag)

      { sender, :smell, {x,y}, :food, _quantity } -> # takeOne,  goHome,  markPath
        send sender, {self, :walk, next_pos_to_home({x,y}), Enum.count(bag)}
        live([1|bag])

      {sender, :ok, {x,y}} ->
        send sender, {self, :walk, next_pos_to_home({x,y}), Enum.count(bag)}
        live(bag)
    # { sender, :smell, {x,y}, :path  } -> moveOn, snort
    end
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

defmodule World do
  @home {0,0}
  pid = spawn(Ant, :live, [[]])
  send pid, {self, :birth, {0,0}}


  def loop(foodPosition) do
    receive do
      {_sender, :walk, {x,y}, _ } when {x,y} == @home  -> IO.puts "Rest In Peace" # no call to loop
      { sender, :walk, {x,y}, _ } ->
        send sender, {self, :ok, {x,y}}
        loop(foodPosition)
      {_sender, :snort, {x,y}, 0 } when {x,y} == @home  -> IO.puts "Got home but will continue to search" # no call to loop
      {sender,  :snort, {x,y}, _} ->
        if Enum.member? foodPosition, {x,y} do
            send sender, {self, :smell, {x,y}, :food, 1}
            loop List.delete( foodPosition, {x,y} )
        else
            send sender, { self, :smell, {x,y}, :grass}
            loop foodPosition
        end
    end
  end
end

:random.seed(:erlang.now) # init randomizer
allCases = for x <- 1..999, y <- 1..999, do: {x,y}
foodPosition = allCases |> Enum.shuffle() |> Enum.take(10)

World.loop(foodPosition)

IO.puts inspect(Ant.moves({1,1}))    # [{2, 1}, {1, 2}, {0, 1}, {1, 0}]
IO.puts inspect( Ant.next_pos({0,0})) # {1,0}
IO.puts Ant.distance({0,0}, {15,0})  # 15.00
