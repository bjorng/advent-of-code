defmodule Day12 do
  def part1(input) do
    parse(input)
  end

  def part2(input) do
    parse(input)
  end

  defp adjacent_squares({row, col}) do
    [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char - ?0}]
      end)
    end)
    |> Map.new
  end
end
