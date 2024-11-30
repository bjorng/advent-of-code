defmodule Day24 do
  use Bitwise

  def part1(input) do
    parse_input(input)
    |> Stream.iterate(&next_state_pt1/1)
    |> Enum.reduce_while(MapSet.new(), fn grid, seen ->
      case MapSet.member?(seen, grid) do
        true ->
          {:halt, rating(grid)}
        false ->
          {:cont, MapSet.put(seen, grid)}
      end
    end)
  end

  def part2(input, minutes \\ 200) do
    parse_input(input)
    |> prepare_grid
    |> Stream.iterate(&next_state_pt2/1)
    |> Enum.at(minutes)
    |> draw_grid
    |> Enum.count
  end

  # Part 1

  defp next_state_pt1(grid) do
    Enum.map(grid, fn {pos, what} ->
      {pos, what, Enum.count(adjacent(pos), fn adj ->
          Map.get(grid, adj, :empty) === :bug
        end)}
    end)
    |> Enum.map(fn {pos, what, n} ->
      {pos, case {what, n} do
              {:bug, 1} -> :bug
              {:empty, 1} -> :bug
              {:empty, 2} -> :bug
              {_, _} -> :empty
            end}
    end)
    |> Map.new
  end

  defp rating(grid) do
    Enum.reduce(grid, 0, fn {{x, y}, what}, acc ->
      case what do
        :bug -> acc + bsl(1, y * 5 + x)
        :empty -> acc
      end
    end)
  end

  # Part 2

  defp next_state_pt2(grid) do
    interesting_tiles(grid)
    |> Enum.map(fn {{{_, _}, _} = pos, what} ->
      {pos, what, Enum.count(adjacent(pos), fn adj ->
          Map.get(grid, adj, :empty) === :bug
        end)}
    end)
    |> Enum.flat_map(fn {pos, what, n} ->
      case {what, n} do
        {:bug, 1} -> [{pos, :bug}]
        {:empty, 1} -> [{pos, :bug}]
        {:empty, 2} -> [{pos, :bug}]
        {_, _} -> []
      end
    end)
    |> Map.new
  end

  defp interesting_tiles(grid) do
    bugs = Map.to_list(grid)
    bugs ++ Enum.flat_map(bugs, fn {pos, _} ->
      Enum.flat_map(adjacent(pos), fn adj ->
        case Map.get(grid, adj, :empty) === :bug do
          true -> []
          false -> [{adj, :empty}]
        end
      end)
    end)
    |> Enum.uniq
  end

  defp prepare_grid(grid) do
    Enum.flat_map(grid, fn {pos, what} ->
      case what do
        :empty -> []
        :bug -> [{{pos, 0}, :bug}]
      end
    end)
    |> Map.new
  end

  defp adjacent({{x, y}, level}) do
    adjacent({x, y})
    |> Enum.flat_map(fn {nx, ny} ->
      case {rem(nx + 5, 5), rem(ny + 5, 5)} do
        {^nx, ^ny} ->
          # Not an outer edge. Check for middle square.
          case {nx, ny} do
            {2, 2} ->
              # Middle
              case x do
                1 ->
                  down_x(0, level + 1)
                3 ->
                  down_x(4, level + 1)
                2 ->
                  case y do
                    1 ->
                      down_y(0, level + 1)
                    3 ->
                      down_y(4, level + 1)
                  end
              end
            {_, _} ->
              # Still on the same level.
              [{{nx, ny}, level}]
          end
        {_, _} ->
          # Go up one level.
          level = level - 1
          up_x(x, level) ++ up_y(y, level)
      end
    end)
    |> Enum.uniq
  end
  defp adjacent({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  defp up_x(0, level), do: [{{1, 2}, level}]
  defp up_x(4, level), do: [{{3, 2}, level}]
  defp up_x(_, _level), do: []

  defp up_y(0, level), do: [{{2, 1}, level}]
  defp up_y(4, level), do: [{{2, 3}, level}]
  defp up_y(_, _level), do: []

  defp down_x(x, level) do
    Enum.map(0..4, & {{x, &1}, level})
  end

  defp down_y(y, level) do
    Enum.map(0..4, & {{&1, y}, level})
  end

  defp parse_input(input) do
    input
    |> Stream.with_index
    |> Enum.reduce([], fn {line, y}, acc ->
      String.to_charlist(line)
      |> Stream.with_index
      |> Enum.reduce(acc, fn {char, x}, acc ->
	pos = {x, y}
	case char do
	  ?\. -> [{pos, :empty} | acc]
	  ?\# -> [{pos, :bug} | acc]
	end
      end)
    end)
    |> Map.new
  end

  defp draw_grid(grid) do
    {{_, min_depth}, {_, max_depth}} =
      grid
      |> Map.keys
      |> Enum.min_max_by(fn {{_, _}, depth} -> depth end)

    Enum.each(min_depth..max_depth,
      fn depth ->
        IO.write "Depth #{depth}:\n"
        draw_one_level(grid, depth)
      end)
    grid
  end

  defp draw_one_level(grid, depth) do
    min_col = 0
    max_col = 4

    grid = 0..4
    |> Enum.reduce(grid, fn row, acc ->
      pos = {{0, row}, depth}
      case Map.has_key?(acc, pos) do
        true ->
          acc
        false ->
          Map.put(acc, pos, :empty)
      end
    end)

    grid
    |> Enum.filter(fn
      {{{_, _}, ^depth}, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {{{col, row}, _depth}, what} ->
      {{col, row}, what}
    end)
    |> Enum.group_by(fn {{_col, row}, _} -> row end)
    |> Enum.sort_by(fn {row, _} -> row end)
    |> Enum.map(fn {row_num, row} ->
      draw_row(row, row_num, min_col..max_col)
    end)
    |> Enum.intersperse("\n")
    |> IO.write
    IO.write("\n\n")
  end

  defp draw_row(row, row_num, col_range) do
    row = Enum.map(row, fn {{col, _row}, color} -> {col, color} end)
    |> Map.new

    col_range
    |> Enum.map(fn col ->
      case Map.get(row, col, :empty) do
	:bug -> ?\#
	:empty when row_num === 2 and col === 2 -> ?\?
	:empty -> ?\.
      end
    end)
  end
end
