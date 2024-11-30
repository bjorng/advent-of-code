defmodule Day11 do
  def part1(string) do
    target_coordinate = String.split(string, ",")
    |> Enum.reduce({0, 0, 0}, &hex_move/2)
    distance(target_coordinate)
  end

  def part2(string) do
    String.split(string, ",")
    |> Stream.scan({0, 0, 0}, &hex_move/2)
    |> Stream.map(&distance/1)
    |> Enum.max
  end

  # https://www.redblobgames.com/grids/hexagons
  # The layout is "odd-q" vertical layout.
  defp hex_move("n",  {x, y, z}), do: {x, y + 1, z - 1}
  defp hex_move("nw", {x, y, z}), do: {x - 1, y + 1, z}
  defp hex_move("ne", {x, y, z}), do: {x + 1, y, z - 1}
  defp hex_move("s",  {x, y, z}), do: {x, y - 1, z + 1}
  defp hex_move("sw", {x, y, z}), do: {x - 1, y, z + 1}
  defp hex_move("se", {x, y, z}), do: {x + 1, y - 1, z}

  defp distance({x, y, z}) do
    Enum.max([abs(x), abs(y), abs(z)])
  end

end
