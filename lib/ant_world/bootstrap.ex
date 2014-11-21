defmodule AntWorld.Bootstrap do

  def world_of_ants(width, height, nb_food, nb_ants) do
    foods = FoodGenerator.random_food_position(width, height, nb_food)
    world_pid = AntWorld.World.start_link(width, height, foods)
    # ant_pid = AntWorld.Ant.start_link( world_pid )
    # send ant_pid, :grass
    # {world_pid, [ant_pid]}
    ants = Enum.map 1..nb_ants, fn (_) -> AntWorld.Ant.start_link( world_pid ) end
    Enum.each ants, fn (ant_pid) -> send ant_pid, :grass end
    {world_pid, ants}
  end
end
