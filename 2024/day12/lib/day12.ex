defmodule Day12 do
  def part1(input) do
    grid = parse(input)
    find_regions(grid)
    |> Enum.map(&cost_part1(&1, grid))
    |> Enum.sum
  end

  defp cost_part1(region, grid) do
    type = Map.fetch!(grid, Enum.min(region))
    perimeter =
      region
      |> Enum.map(fn plot ->
        adjacent_squares(plot)
        |> Enum.count(&fence?(grid, type, &1))
      end)
      |> Enum.sum

    area = Enum.count(region)

    area * perimeter
  end

  def part2(input) do
    grid = parse(input)

    find_regions(grid)
    |> Enum.map(&cost_part2(&1, grid))
    |> Enum.sum
  end

  defp cost_part2(region, grid) do
    type = Map.fetch!(grid, Enum.min(region))
    sides = region
    |> Enum.flat_map(fn plot ->
      plot
      |> adjacent_squares
      |> Enum.filter(&fence?(grid, type, &1))
      |> Enum.map(fn square ->
        diff = sub(plot, square)
        axis = if elem(diff, 1) === 0, do: 0, else: 1
        other_axis = rem(axis + 1, 2)
        {{diff, elem(plot, axis)}, elem(plot, other_axis)}
      end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.values
    |> Enum.flat_map(fn span ->
      span
      |> Enum.sort
      |> Enum.chunk_while([],
      fn el, acc ->
        case acc do
          [prev | _] when el === prev + 1 ->
            {:cont, [el | acc]}
          [] ->
            {:cont, [el | acc]}
          _ ->
            {:cont, Enum.reverse(acc), [el]}
        end
      end, fn acc ->
        case acc do
          [] -> {:cont, []}
          [_ | _] ->  {:cont, Enum.reverse(acc), []}
        end
      end)
    end)
    |> Enum.count

    area = Enum.count(region)

    area * sides
  end

  defp find_regions(grid) do
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

  defp fence?(grid, type, position) do
    Map.get(grid, position, nil) !== type
  end

  defp sub({a, b}, {c, d}), do: {a - c, b - d}

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
        [{position, char}]
      end)
    end)
    |> Map.new
  end
end
