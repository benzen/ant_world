defmodule Ant_world.World do
  require Ant_world.Ant
  # import IO, only: [inspect: 1]

  # IO.puts "WORLD: I'm alive"
  @home {0,0}

  def loop(food_position \\ []) do
    receive do
      {:init, food_position} ->
        pid = spawn(Ant_world.Ant, :loop, [])
        send pid, {self, :birth, {0,0}}
        # IO.puts "food_position #{inspect(food_position)}"
        loop(food_position)

      {_sender, :walk, {x,y}, _ } when {x,y} == @home  -> IO.puts "Rest In Peace" # no call to loop

      { sender, :walk, {x,y}, _ } ->
        IO.puts "WORLD: walked"
        send sender, {self, :ok, {x,y}}
        loop(food_position)

      {_sender, :snort, {x,y}, 0 } when {x,y} == @home  ->
         IO.puts "Got home but will continue to search"
         loop( food_position)
      {sender,  :snort, {x,y}, _count_in_bag} ->
        IO.puts "WORLD: snorted #{x},#{y}"
        if Enum.member? food_position, {x,y} do
            IO.puts "WORLD: is on foods"
            send sender, {self, :smell, {x,y}, :food, 1}
            loop( List.delete( food_position, {x,y} ))
        else
            IO.puts "WORLD: is on Grass"
            send sender, { self, :smell, {x,y}, :grass}
            loop( food_position)
        end

    end

  end

end
