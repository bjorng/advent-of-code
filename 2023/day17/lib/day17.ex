defmodule Day17 do
  def part1(input) do
    {{_..max_row, _..max_col}, grid} = parse(input)
    start = {0, 0}
    target = {max_row, max_col}
    loss = 0
    dir = {-1, -1}
    current = {loss, {start, 0, dir}}
    seen = MapSet.new()
    q = :gb_sets.singleton(current)
    find_path_part1(q, grid, target, seen)
  end

  defp find_path_part1(q, grid, target, seen) do
    {smallest, q} = :gb_sets.take_smallest(q)
    {loss, {pos, steps, dir}} = smallest
    if pos === target do
      loss
    else
      ns = directions()
      |> Enum.flat_map(fn new_dir ->
        new_pos = add(pos, new_dir)
        cond do
          not Map.has_key?(grid, new_pos) ->
            []
          dir === new_dir ->
            steps = steps + 1
            if steps === 4 do
              []
            else
              [{add(pos, dir), steps, new_dir}]
            end
          rotate180(new_dir) === dir ->
            []
          true ->
            [{new_pos, 1, new_dir}]
        end
        |> Enum.reject(fn key ->
          MapSet.member?(seen, key)
        end)
      end)

      seen = Enum.reduce(ns, seen, fn key, seen ->
        MapSet.put(seen, key)
      end)

      q = Enum.reduce(ns, q, fn {new_pos, _, _} = key, q ->
        loss = loss + Map.fetch!(grid, new_pos)
        elem = {loss, key}
        :gb_sets.insert(elem, q)
      end)

      find_path_part1(q, grid, target, seen)
    end
  end

  def part2(input) do
    {{_..max_row, _..max_col}, grid} = parse(input)
    start = {0, 0}
    target = {max_row, max_col}
    loss = 0
    dir = {-1, -1}
    current = {loss, {start, 0, dir}}
    seen = MapSet.new()
    q = :gb_sets.singleton(current)
    find_path_part2(q, grid, target, seen)
  end

  defp find_path_part2(q, grid, target, seen) do
    {smallest, q} = :gb_sets.take_smallest(q)
    {loss, {pos, steps, dir}} = smallest
    if steps >= 4 and pos === target do
      loss
    else
      ns = directions()
      |> Enum.flat_map(fn new_dir ->
        new_pos = add(pos, new_dir)
        cond do
          not Map.has_key?(grid, new_pos) ->
            []
          dir === new_dir ->
            steps = steps + 1
            if steps === 11 do
              []
            else
              [{add(pos, dir), steps, new_dir}]
            end
          rotate180(new_dir) === dir ->
            []
          true ->
            if steps === 0 or steps >= 4 do
              [{new_pos, 1, new_dir}]
            else
              []
            end
        end
        |> Enum.reject(fn key ->
          MapSet.member?(seen, key)
        end)
      end)

      seen = Enum.reduce(ns, seen, fn key, seen ->
        MapSet.put(seen, key)
      end)

      q = Enum.reduce(ns, q, fn {new_pos, _steps, _dir} = key, q ->
        loss = loss + Map.fetch!(grid, new_pos)
        elem = {loss, key}
        :gb_sets.insert(elem, q)
      end)

      find_path_part2(q, grid, target, seen)
    end
  end

  defp add({row0, col0}, {row1, col1}) do
    {row0 + row1, col0 + col1}
  end

  defp directions() do
    [{-1, 0},
     {0, -1}, {0,1},
     {1, 0}]
  end

  defp rotate180({row, col}), do: {-row, -col}

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.map(fn {char, col} ->
        position = {row, col}
        {position, char - ?0}
      end)
    end)
    |> Map.new
    |> then(fn map ->
      {max_row, _} = Enum.max_by(Map.keys(map), &elem(&1, 0))
      {_, max_col} = Enum.max_by(Map.keys(map), &elem(&1, 1))
      {{0..max_row, 0..max_col}, map}
    end)
  end
end
