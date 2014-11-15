defmodule FoodGenerator do

  def random_food_position(width, height, nb) do
    :random.seed(:erlang.now) # init randomizer
    generate_unique_positions(width, height, nb)
  end

  defp generate_unique_positions(width, height, nb) do
    generate_unique_positions_rec(width, height, nb, [])
  end

  defp generate_unique_positions_rec(_width, _height, nb, acc) when length(acc) == nb do
    acc
  end

  defp generate_unique_positions_rec(width, height, nb, acc) do
      np = generate_random_position(width, height)
      if Enum.member? acc, np do
         generate_unique_positions_rec width, height, nb, acc
       else
         generate_unique_positions_rec width, height, nb, [np|acc]
      end
  end

  defp generate_random_position(width, height) do
    x = :random.uniform(width)
    y = :random.uniform(height)
    {x,y}
  end

end
