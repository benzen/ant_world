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
