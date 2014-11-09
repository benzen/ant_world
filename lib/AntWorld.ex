defmodule AntWorld do
  require Ant_world.World

  def main() do
    {:ok, world_pid} = GenServer.start_link(Ant_world.World, [random_food_position()])
    Ant_world.Ant.init(world_pid)

  end

  def random_food_position() do
    :random.seed(:erlang.now) # init randomizer
    all_cases = for x <- 1..999, y <- 1..999, do: {x,y}
    all_cases |> Enum.shuffle() |> Enum.take(10)
  end

end
