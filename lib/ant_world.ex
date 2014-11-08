defmodule AntWorld do
  require Ant_world.World

  def main() do
    pid = spawn( Ant_world.World, :loop, [])
    send pid, {:init, random_food_position()}

  end

  def random_food_position() do
    :random.seed(:erlang.now) # init randomizer
    all_cases = for x <- 1..999, y <- 1..999, do: {x,y}
    all_cases |> Enum.shuffle() |> Enum.take(10)
  end

end
