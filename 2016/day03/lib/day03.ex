defmodule Day03 do
  def part1(input) do
    parse(input)
    |> Enum.count(&is_possible?/1)
  end

  def part2(input) do
    parse(input)
    |> Enum.chunk_every(3)
    |> Enum.flat_map(fn triangles ->
      triangles
      |> Enum.zip
      |> Enum.map(&Tuple.to_list/1)
    end)
    |> Enum.count(&is_possible?/1)
  end

  defp is_possible?(triangle) do
    permutations(triangle)
    |> Enum.all?(fn [a, b, c] ->
      a < b + c
    end)
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for el <- list, rest <- permutations(list--[el]) do
      [el | rest]
    end
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      String.split(line, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
