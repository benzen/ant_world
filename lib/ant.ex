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
