defmodule Day18 do
  use Bitwise

  def part1(input, steps \\ 100) do
    parse(input)
    |> Stream.iterate(&next_state_part1/1)
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> hd
    |> count_lights
  end

  def part2(input, steps \\ 100) do
    parse(input)
    |> stick_lights
    |> Stream.iterate(&next_state_part2/1)
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> hd
    |> count_lights
  end

  defp next_state_part1(grid) do
    keys = Map.keys(grid)
    Enum.reduce(keys, grid, fn row_col, acc ->
      case count_neighbors(row_col, grid) do
        2 ->
          acc
        3 ->
          Map.put(acc, row_col, ?\#)
        _ ->
          Map.put(acc, row_col, ?\.)
      end
    end)
  end

  defp next_state_part2(grid) do
    grid
    |> next_state_part1
    |> stick_lights
  end

  defp count_neighbors({row, col}, grid) do
    neighbors = [{row - 1, col - 1},
                 {row - 1, col},
                 {row - 1, col + 1},
                 {row, col - 1},
                 {row, col + 1},
                 {row + 1, col - 1},
                 {row + 1, col},
                 {row + 1, col + 1}]
    Enum.count(neighbors, fn row_col ->
      Map.get(grid, row_col, ?.) === ?\#
    end)
  end

  defp count_lights(grid) do
    Enum.count(grid, fn {_, light} -> light === ?\# end)
  end

  defp stick_lights(grid) do
    high = round(:math.sqrt(map_size(grid))) - 1
    [{0, 0}, {0, high}, {high, 0}, {high, high}]
    |> Enum.reduce(grid, fn row_col, acc ->
      Map.put(acc, row_col, ?\#)
    end)
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.map(&parse_grid_line/1)
    |> Enum.concat
    |> Map.new
  end

  defp parse_grid_line({line, row}) do
    line
    |> String.to_charlist
    |> Enum.with_index
    |> Enum.map(fn {char, col} ->
      {{row, col}, char}
    end)
  end

end
