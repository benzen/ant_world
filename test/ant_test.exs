defmodule Ant_world.AntTest do
  use ExUnit.Case

  test "moves propose all possibile moves from given starting point" do
    assert Ant_world.Ant.moves({1,1}) == [{2, 1}, {1, 2}, {0, 1}, {1, 0}]
  end

  test "next_post give a random next position that is valid" do
    assert Enum.member?( [{1,0}, {0,1}], Ant_world.Ant.next_pos({0,0}))
  end

  test "distance calculate distance between two position" do
    assert Ant_world.Ant.distance({0,0}, {15,0}) == 15
  end

end
