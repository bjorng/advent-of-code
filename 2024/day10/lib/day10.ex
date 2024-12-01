defmodule Day10 do
  def part1(input) do
    get_goals(input)
    |> Enum.map(fn goals ->
      goals
      |> Enum.uniq
      |> Enum.count
    end)
    |> Enum.sum
  end

  def part2(input) do
    get_goals(input)
    |> Enum.map(&Enum.count/1)
    |> Enum.sum
  end

  defp get_goals(input) do
    map = parse(input)
    map
    |> Enum.filter(fn {_, height} -> height === 0 end)
    |> Enum.map(fn {position, 0} ->
      get_goals(map, position, 1)
    end)
  end

  defp get_goals(map, position, height) do
    adjacent_squares(position)
    |> Enum.flat_map(fn next ->
      case map do
        %{^next => 9} when height === 9 ->
          [next]
        %{^next => ^height} ->
          get_goals(map, next, height + 1)
        %{} ->
          []
      end
    end)
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
