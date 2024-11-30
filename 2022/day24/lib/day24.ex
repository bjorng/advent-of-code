defmodule Day24 do
  def part1(input) do
    grid = parse(input)
    {grid, from, to} = init(grid)
    find_path(grid, from, to, 0)
  end

  def part2(input) do
    grid = parse(input)
    {grid, from, to} = init(grid)
    steps = find_path(grid, from, to, 0)
    steps = find_path(grid, to, from, steps)
    find_path(grid, from, to, steps)
  end

  defp init(grid) do
    {{max_row, _}, _} =
      Enum.max_by(grid, fn {{row, _}, _} -> row end)
    {{_, max_col}, _} =
      Enum.max_by(grid, fn {{_, col}, _} -> col end)
    grid = Map.new(grid)
    |> Map.put({-2, 0}, :wall)
    |> Map.put({max_row + 1, max_col - 1}, :wall)
    from = {-1, 0}
    to = {max_row, max_col - 1}
    :empty = Map.fetch!(grid, from)
    :empty = Map.fetch!(grid, to)
    {{grid, max_row, max_col}, from, to}
  end

  defp find_path(grid, from, to, steps) do
    distance = manhattan_distance(from, to)
    q = :gb_sets.singleton({steps, distance, from})
    seen = MapSet.new([{from, steps}])
    do_find_path(grid, q, seen, to)
  end

  defp do_find_path(grid, q, seen, to) do
    {{steps, _, position}, q} = :gb_sets.take_smallest(q)
    if position === to do
      steps
    else
      steps = steps + 1
      {q, seen} =
        Enum.reduce(nearby(position, grid), {q, seen}, fn neighbor, {q, seen} ->
          case blizzard?(grid, neighbor, steps) do
            false ->
              seen_key = {neighbor, steps}
              case MapSet.member?(seen, seen_key) do
                true ->
                  {q, seen}
                false ->
                  key = {steps, manhattan_distance(neighbor, to), neighbor}
                  {:gb_sets.add(key, q), MapSet.put(seen, seen_key)}
              end
            true ->
              {q, seen}
          end
        end)
      do_find_path(grid, q, seen, to)
    end
  end

  defp blizzard?(_, {-1, 0}, _time) do
    false
  end
  defp blizzard?({_grid, max_row, max_col}, {max_row, col}, _time) when (col === max_col - 1) do
    false
  end
  defp blizzard?({grid, max_row, max_col}, {row, col}, time) do
    nearby = [{-1, 0, :down},
              {0, -1, :right}, {0, 1, :left},
              {1, 0, :up}]
    Enum.any?(nearby, fn {row_mul, col_mul, must_be} ->
      position = {modulo(row + row_mul * time, max_row),
                  modulo(col + col_mul * time, max_col)}
      case grid do
        %{^position => ^must_be} -> true
        %{^position => _} -> false
      end
    end)
  end

  defp modulo(a, b) do
    case rem(a, b) do
      c when c >= 0 -> c
      c -> modulo(c + b, b)
    end
  end

  defp nearby({row, col}, {grid, _, _}) do
    [{row - 1, col},
     {row, col - 1}, {row, col}, {row, col + 1},
     {row + 1, col}]
     |> Enum.filter(fn position ->
      Map.fetch!(grid, position) !== :wall
    end)
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp parse(input) do
    input
    |> Enum.with_index(-1)
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index(-1)
      |> Enum.map(fn {char, col} ->
        char = case char do
                 ?< -> :left
                 ?> -> :right
                 ?^ -> :up
                 ?v -> :down
                 ?\# -> :wall
                 ?. -> :empty
               end
        {{row, col}, char}
      end)
    end)
  end

  def draw_grid({grid, max_row, max_col} = g, expedition, time) do
    Enum.each(-1..max_row, fn row ->
      Enum.map(-1..max_col, fn col ->
        position = {row, col}
        case Map.fetch!(grid, position) do
          _ when position === expedition ->
            ?E
          :wall ->
            ?\#
          _ ->
            case blizzard?(g, position, time) do
              true -> ?o
              false -> ?.
            end
        end
      end)
      |> IO.puts
    end)
  end
end
