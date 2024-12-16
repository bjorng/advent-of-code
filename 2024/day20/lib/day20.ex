defmodule Day20 do
  def part1(input, limit \\ 100) do
    solve(input, 2, limit)
  end

  def part2(input, limit \\ 100) do
    solve(input, 20, limit)
  end

  defp solve(input, cheat_steps, limit) do
    {grid, start, finish} = parse(input)
    steps_to_finish = cache_steps_to_finish(start, finish, grid)

    steps_to_finish
    |> Enum.map(fn {origin, max_steps} ->
      accept? = fn next, distance ->
        case steps_to_finish do
          %{^next => steps} ->
            saved = max_steps - steps - distance
            saved >= limit
          %{} ->
            # Invalid end location (wall or outside of the map).
            false
        end
      end
      count_cheats(origin, cheat_steps, accept?)
    end)
    |> Enum.sum
  end

  # Count the number of possible end locations for the
  # cheat that starts at origin.
  defp count_cheats({row, col} = origin, steps, accept?) do
    count = 0
    row_range = row - steps .. row + steps
    col_range = col - steps .. col + steps
    Enum.reduce(row_range, count, fn row, count ->
      Enum.reduce(col_range, count, fn col, count ->
        next = {row, col}
        distance = manhattan_distance(next, origin)
        if distance <= steps and next !== origin and
        accept?.(next, distance) do
          count + 1
        else
          count
        end
      end)
    end)
  end

  defp cache_steps_to_finish(start, finish, grid) do
    do_cache_steps_to_finish(start, finish, grid, MapSet.new())
    |> elem(1)
    |> Map.new
  end

  defp do_cache_steps_to_finish(current, finish, grid, seen) do
    if current === finish do
      {1, [{current, 0}]}
    else
      next = adjacent_squares(current)
      |> Enum.find(fn next ->
        empty?(next, grid) and next not in seen
      end)
      seen = MapSet.put(seen, next)
      {steps, acc} = do_cache_steps_to_finish(next, finish, grid, seen)
      {steps + 1, [{current, steps} | acc]}
    end
  end

  defp manhattan_distance({a, b}, {c, d}) do
    abs(a - c) + abs(b - d)
  end

  defp empty?(where, grid) do
    case grid do
      %{^where => ?\.} -> true
      %{} -> false
    end
  end

  defp adjacent_squares({row, col}) do
    [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
  end

  defp parse(input) do
    grid = parse_grid(input)

    {start, ?S} = Enum.find(grid, &elem(&1, 1) === ?S)
    {finish, ?E} = Enum.find(grid, &elem(&1, 1) === ?E)

    grid = %{grid | start => ?., finish => ?.}

    {grid, start, finish}
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
