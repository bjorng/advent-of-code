defmodule Day17 do
  def part1(input), do: Day17Part1.part1(input)
  def part2(input), do: Day17Part2.part2(input)
end

#
# Part 1.
#

defmodule Day17Part1 do
  def part1(input) do
    grid = parse(input)
    Stream.iterate(grid, &next_state/1)
    |> Stream.drop(6)
    |> Enum.take(1)
    |> hd
    |> MapSet.size
  end

  def next_state(grid) do
    {xr, yr, zr} = bounds(grid)
    Enum.reduce(xr, grid, fn x, new_grid ->
      Enum.reduce(yr, new_grid, fn y, new_grid ->
        Enum.reduce(zr, new_grid, fn z, new_grid ->
          pos = {x, y, z}
          case MapSet.member?(grid, pos) do
            true ->
              case count_neighbors(pos, grid) do
                2 -> new_grid
                3 -> new_grid
                _ -> MapSet.delete(new_grid, pos)
              end
            false ->
              case count_neighbors(pos, grid) do
                3 -> MapSet.put(new_grid, pos)
                _ -> new_grid
              end
          end
        end)
      end)
    end)
  end

  defp bounds(grid) do
    grid
    |> MapSet.to_list
    |> Enum.reduce({0..0, 0..0, 0..0}, fn {x, y, z}, {xr, yr, zr} ->
      {update_range(x, xr), update_range(y, yr), update_range(z, zr)}
    end)
  end

  defp update_range(val, first..last = range) do
    cond do
      val - 1 < first -> val-1..last
      val + 1 > last -> first..val+1
      true -> range
    end
  end

  defp count_neighbors(pos, grid) do
    Enum.count(neighbors(pos), fn pos ->
      MapSet.member?(grid, pos)
    end)
  end

  defp neighbors({ox, oy, oz} = point) do
    for x <- ox-1..ox+1,
      y <- oy-1..oy+1,
      z <- oz-1..oz+1, {x, y, z} != point do
      {x, y, z}
    end
  end

  defp parse(input) do
    init = {{0, 0}, MapSet.new()}
    {_, grid} = input
    |> Enum.reduce(init, fn row, {{x, y}, grid} ->
      {_, grid} = row
      |> String.to_charlist()
      |> Enum.reduce({x, grid}, fn char, {x, grid} ->
        grid = case char do
                 ?\# ->
                   MapSet.put(grid, {x, y, 0})
                 ?. ->
                   grid
               end
        {x + 1, grid}
      end)
      {{x, y + 1}, grid}
    end)
    grid
  end
end

#
# Part 2.  This is just a copy of part 1 with an added dimension.
#

defmodule Day17Part2 do
  def part2(input) do
    grid = parse(input)
    Stream.iterate(grid, &next_state/1)
    |> Stream.drop(6)
    |> Enum.take(1)
    |> hd
    |> MapSet.size
  end

  defp next_state(grid) do
    {xr, yr, zr, wr} = bounds(grid)
    Enum.reduce(xr, grid, fn x, new_grid ->
      Enum.reduce(yr, new_grid, fn y, new_grid ->
        Enum.reduce(zr, new_grid, fn z, new_grid ->
          Enum.reduce(wr, new_grid, fn w, new_grid ->
            pos = {x, y, z, w}
            case MapSet.member?(grid, pos) do
              true ->
                case count_neighbors(pos, grid) do
                  2 -> new_grid
                  3 -> new_grid
                  _ -> MapSet.delete(new_grid, pos)
                end
              false ->
                case count_neighbors(pos, grid) do
                  3 -> MapSet.put(new_grid, pos)
                  _ -> new_grid
                end
            end
          end)
        end)
      end)
    end)
  end

  defp bounds(grid) do
    grid
    |> MapSet.to_list
    |> Enum.reduce({0..0, 0..0, 0..0, 0..0}, fn {x, y, z, w}, {xr, yr, zr, wr} ->
      {update_range(x, xr), update_range(y, yr),
       update_range(z, zr), update_range(w, wr)}
    end)
  end

  defp update_range(val, first..last = range) do
    cond do
      val - 1 < first -> val-1..last
      val + 1 > last -> first..val+1
      true -> range
    end
  end

  defp count_neighbors(pos, grid) do
    Enum.count(neighbors(pos), fn pos ->
      MapSet.member?(grid, pos)
    end)
  end

  defp neighbors({ox, oy, oz, ow} = point) do
    for x <- ox-1..ox+1,
      y <- oy-1..oy+1,
      z <- oz-1..oz+1,
      w <- ow-1..ow+1, {x, y, z, w} != point do
      {x, y, z, w}
    end
  end

  defp parse(input) do
    init = {{0, 0}, MapSet.new()}
    {_, grid} = input
    |> Enum.reduce(init, fn row, {{x, y}, grid} ->
      {_, grid} = row
      |> String.to_charlist()
      |> Enum.reduce({x, grid}, fn char, {x, grid} ->
        grid = case char do
                 ?\# ->
                   MapSet.put(grid, {x, y, 0, 0})
                 ?. ->
                   grid
               end
        {x + 1, grid}
      end)
      {{x, y + 1}, grid}
    end)
    grid
  end
end
