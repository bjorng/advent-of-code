defmodule Day11 do
  def part1(input) do
    parse(input)
    |> expand(2)
    |> sum_distances
  end

  def part2(input, factor \\ 1000000) do
    parse(input)
    |> expand(factor)
    |> sum_distances
  end

  defp expand(image, factor) do
    image
    |> translate(0, factor)
    |> translate(1, factor)
  end

  defp translate(image, index, factor) do
    factor = factor - 1
    map = image
    |> Enum.map(&elem(&1, index))
    |> Enum.sort
    |> Enum.dedup
    |> Enum.with_index
    |> Enum.reduce({0, %{}}, fn {coordinate, n}, {offset, map} ->
      map = Map.put(map, coordinate, coordinate + factor * (coordinate - n))
      if coordinate === offset do
        {offset, map}
      else
        {offset + 1, map}
      end
    end)
    |> then(&elem(&1, 1))
    |> Map.new
    Enum.map(image, fn galaxy  ->
      put_elem(galaxy, index, Map.fetch!(map, elem(galaxy, index)))
    end)
  end

  defp sum_distances(image) do
    Enum.flat_map(image, fn galaxy1 ->
      Enum.flat_map(image, fn galaxy2 ->
        if galaxy1 < galaxy2 do
          [{galaxy1, galaxy2}]
        else
          []
        end
      end)
    end)
    |> Enum.map(&manhattan_distance(elem(&1, 0), elem(&1, 1)))
    |> Enum.sum
  end

  defp manhattan_distance({row, col}, {row1, col1}) do
    abs(row - row1) + abs(col - col1)
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.to_charlist
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        case char do
          ?. -> []
          ?\# -> [{row, col}]
        end
      end)
    end)
  end
end
