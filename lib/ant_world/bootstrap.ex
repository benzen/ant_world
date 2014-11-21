defmodule AntWorld.Bootstrap do

  def world_of_ants(width, height, nb_food, nb_ants) do
    foods = FoodGenerator.random_food_position(width, height, nb_food)
    world_pid = AntWorld.World.start_link(width, height, foods)

    ants = Enum.map 1..nb_ants, fn (_) ->
      ant_pid = AntWorld.Ant.start_link( world_pid )
      send ant_pid, :grass
      ant_pid
    end
    {world_pid, ants}
  end
end
