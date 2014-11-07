defmodule AntWorld do

    :random.seed(:erlang.now) # init randomizer
    allCases = for x <- 1..999, y <- 1..999, do: {x,y}
    foodPosition = allCases |> Enum.shuffle() |> Enum.take(10)

    World.loop(foodPosition)


end
