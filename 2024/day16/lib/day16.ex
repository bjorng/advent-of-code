defmodule Day16 do
  def part1(input) do
    {grid, start, finish} = parse(input)
    visited = MapSet.new()
    :gb_sets.singleton({0, start, {0, 1}, []})
    |> find_paths(grid, finish, visited, nil)
  end

  def part2(input) do
    {grid, start, finish} = parse(input)
    visited = MapSet.new()
    :gb_sets.singleton({0, start, {0, 1}, []})
    |> find_paths(grid, finish, visited, :infinity)
    |> Enum.map(&:ordsets.from_list/1)
    |> :ordsets.union
    |> length
  end

  defp find_paths(paths, grid, finish, visited, max_score) do
    case queue_next(paths) do
      nil ->
        []
      {{score, ^finish, _dir, _passed}, _paths} when max_score === nil ->
        score
      {{score, ^finish, _dir, passed}, paths} ->
        if score <= max_score do
          max_score = min(max_score, score)
          passed = [finish|passed]
          [passed | find_paths(paths, grid, finish, visited, max_score)]
        else
          []
        end
      {{score, current, dir, passed}, paths} ->
        visited = MapSet.put(visited, {current, dir})
        passed = case passed do
                   [^current|_] -> passed
                   _ when max_score === nil -> []
                   _ -> [current|passed]
                 end
        paths =
          [forward_path(grid, finish, score, current, dir, passed)|
           rotated_paths(grid, score, current, dir, passed)]
          |> extend_paths(grid, paths, visited)
        find_paths(paths, grid, finish, visited, max_score)
    end
  end

  defp queue_next(paths) do
    case :gb_sets.is_empty(paths) do
      true ->
        nil
      false ->
        :gb_sets.take_smallest(paths)
    end
  end

  defp forward_path(grid, finish, score, current, dir, passed) do
    next = add(current, dir)
    if ((not wall?(grid, next)) and
      next !== finish and
      wall?(grid, add(next, rotate90a(dir))) and
      wall?(grid, add(next, rotate90b(dir)))) do
      forward_path(grid, finish, score + 1, next, dir, [next|passed])
    else
      {score + 1, next, dir, passed}
    end
  end

  defp rotated_paths(grid, score, current, dir, passed) do
    [{score + 1000, current, rotate90a(dir), passed},
     {score + 1000, current, rotate90b(dir), passed}]
     |> Enum.reject(fn {_, current, dir, _} ->
      wall?(grid, add(current, dir))
    end)
  end

  defp wall?(grid, position), do: Map.fetch!(grid, position) === ?\#

  defp extend_paths([{score, current, dir, passed}|rest], grid, paths, visited) do
    cond do
      wall?(grid, current) ->
        extend_paths(rest, grid, paths, visited)
      MapSet.member?(visited, {current, dir}) ->
        extend_paths(rest, grid, paths, visited)
      true ->
        paths = :gb_sets.add({score, current, dir, passed}, paths)
        extend_paths(rest, grid, paths, visited)
    end
  end
  defp extend_paths([], _, paths, _), do: paths

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp rotate90a({a, b}), do: {-b, a}
  defp rotate90b({a, b}), do: {b, -a}

  defp parse(input) do
    grid = parse_grid(input)

    {start, ?S} = Enum.find(grid, &elem(&1, 1) === ?S)
    {finish, ?E} = Enum.find(grid, &elem(&1, 1) === ?E)

    grid = %{grid | start => ?., finish => ?E}

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
