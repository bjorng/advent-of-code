defmodule Day12 do
  def part1(input) do
    grid = parse(input)
    seen = MapSet.new()
    grid
    |> Enum.flat_map_reduce(seen, fn {plot, type}, seen ->
      if plot in seen do
        {[], seen}
      else
        region = find_region(plot, type, grid)
        seen = MapSet.union(seen, region)
        {[region], seen}
      end
    end)
    |> then(&elem(&1, 0))
    |> Enum.map(&area_and_perimeter(&1, grid))
    |> Enum.sum
  end

  defp area_and_perimeter(region, grid) do
    region = MapSet.to_list(region)
    type = Map.fetch!(grid, hd(region))
    perimeter =
      region
      |> Enum.map(fn plot ->
        adjacent_squares(plot)
        |> Enum.reject(fn adjacent ->
          Map.get(grid, adjacent, nil) === type
        end)
        |> Enum.count
      end)
      |> Enum.sum

    area = Enum.count(region)

    area * perimeter
  end

  defp find_region(plot, type, grid) do
    find_region([plot], type, grid, MapSet.new())
  end

  defp find_region([plot|plots], type, grid, region) do
    cond do
      plot in region ->
        find_region(plots, type, grid, region)
      Map.get(grid, plot, nil) === type ->
        region = MapSet.put(region, plot)
        plots = adjacent_squares(plot) ++ plots
        find_region(plots, type, grid, region)
      true ->
        find_region(plots, type, grid, region)
    end
  end
  defp find_region([], _type, _grid, region), do: region

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
