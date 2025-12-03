defmodule Day04 do
  def part1(input) do
    grid = parse(input)
    Enum.count(removable(grid))
  end

  def part2(input) do
    grid = parse(input)
    remove(grid, 0)
  end

  defp remove(grid, num_removed) do
    case removable(grid) do
      [] ->
        num_removed
      [_|_]=ps ->
        grid = Enum.reduce(ps, grid, &(Map.delete(&2, &1)))
        remove(grid, num_removed + length(ps))
    end
  end

  defp removable(grid) do
    grid
    |> Enum.filter(fn {_position, what} -> what === ?@ end)
    |> Enum.filter(fn {position, _} ->
      adjacent_squares(position)
      |> Enum.count(fn position->
        get_grid(grid, position) === ?@
      end)
      |> then(&(&1 < 4))
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp get_grid(grid, position) do
    Map.get(grid, position, ?.)
  end

  defp adjacent_squares({row, col}) do
    [{row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
     {row, col - 1}, {row, col + 1},
     {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}]
  end

  defp parse(input) do
    parse_grid(input)
  end

  defp parse_grid(grid) do
    grid
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> Map.new
  end
end
