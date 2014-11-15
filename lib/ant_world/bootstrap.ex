defmodule AntWorld.Bootstrap do

  def world_of_ants(width, height, nb) do
    foods = FoodGenerator.random_food_position(width, height, nb)
    world_pid = AntWorld.World.start_link(width, height, foods)
    ant_pid = AntWorld.Ant.start_link( world_pid)
    send ant_pid, :grass
    {world_pid, [ant_pid]}
  end
end
