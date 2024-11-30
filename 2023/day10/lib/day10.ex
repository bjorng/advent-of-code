defmodule Day10 do
  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def part1(input) do
    {start, map} = parse(input)
    Map.new(map)
    |> fix_map(start)
    |> find_path(start)
    |> Enum.count
    |> then(&div(&1, 2))
  end

  defp find_path(map, position) do
    [direction | _] = map[position]
    find_path(position, direction, map, position)
  end

  defp find_path(from, direction, map, target) do
    case add(from, direction) do
      ^target ->
        [from, target]
      to ->
        reverse_direction = rotate180(direction)
        case Map.fetch!(map, to) do
          [^reverse_direction, next] ->
            [from | find_path(to, next, map, target)]
          [next, ^reverse_direction] ->
            [from | find_path(to, next, map, target)]
        end
    end
  end

  def part2(input) do
    parse(input)
    {start, map} = parse(input)
    map = map
    |> Map.new
    |> fix_map(start)
    |> remove_junk_pipes(start)
    {left, right} = find_seeds(map, start)
    left = flood_fill(left, map)
    right = flood_fill(right, map)
    (left || right)
#    |> print_grid(map)
    |> MapSet.size
  end

  defp remove_junk_pipes(map, start) do
    main_loop = find_path(map, start)
    |> MapSet.new
    Enum.reduce(map, map, fn {position, _}, map ->
      case MapSet.member?(main_loop, position) do
        true ->
          map
        false ->
          Map.delete(map, position)
      end
    end)
  end

  defp find_seeds(map, start) do
    [direction | _] = map[start]
    left = right = MapSet.new()
    find_seeds(start, direction, map, start, left, right)
  end

  defp find_seeds(from, direction, map, target, l_seeds, r_seeds) do
    rot = rotate90(direction)
    position = add(from, direction)

    left = add(position, rot)
    right = add(position, rotate180(rot))

    l_seeds = update_seeds(l_seeds, map, left)
    r_seeds = update_seeds(r_seeds, map, right)

    directions = Map.fetch!(map, position)
    other = other_direction(directions, direction)

    rot2 = rotate90(other)
    left2 = add(position, rot2)
    right2 = add(position, rotate180(rot2))

    l_seeds = update_seeds(l_seeds, map, left2)
    r_seeds = update_seeds(r_seeds, map, right2)

    if position === target do
      {l_seeds, r_seeds}
    else
      find_seeds(position, other, map, target, l_seeds, r_seeds)
    end
  end

  defp update_seeds(seeds, map, direction) do
    case Map.has_key?(map, direction) do
      true -> seeds
      false -> MapSet.put(seeds, direction)
    end
  end

  defp rotate90({row, col}), do: {col, -row}

  defp rotate180({row, col}), do: {-row, -col}

  defp fix_map(map, start) do
    map = Map.put(map, start, [])
    @directions
    |> Enum.reduce(map, fn direction, map ->
      pos = add(start, direction)
      case path?(map, pos, start) do
        true ->
          Map.update!(map, start, &Enum.sort([sub(pos, start) | &1]))
        false ->
          map
      end
    end)
  end

  defp add({row0, col0}, {row1, col1}) do
    {row0 + row1, col0 + col1}
  end

  defp sub({row0, col0}, {row1, col1}) do
    {row0 - row1, col0 - col1}
  end

  defp path?(map, from, to) do
    Enum.any?(Map.get(map, from, []), fn direction ->
      add(from, direction) === to
    end)
  end

  defp other_direction(directions, direction) do
    reverse_direction = rotate180(direction)
    case directions do
      [^reverse_direction, other] -> other
      [other, ^reverse_direction] -> other
    end
  end

  defp flood_fill(positions, map) do
    {{max_row, _}, _} = Enum.max_by(map, fn {{row, _}, _} -> row end)
    {{_, max_col}, _} = Enum.max_by(map, fn {{_, col}, _} -> col end)
    row_limit = 0..max_row
    col_limit = 0..max_col
    limits = {row_limit, col_limit}
    flood_fill(positions, positions, map, limits)
  end

  defp flood_fill(positions, filled, map, limits) do
    new_positions = do_flood_fill(positions, filled, map, limits)
    if new_positions === nil do
      nil
    else
      case MapSet.size(new_positions) do
        0 ->
          filled
        _ ->
          filled = MapSet.union(new_positions, filled)
          flood_fill(new_positions, filled, map, limits)
      end
    end
  end

  defp do_flood_fill(positions, filled, map, {row_limit, col_limit}) do
    Enum.reduce(positions, MapSet.new(), fn pos, new_positions ->
      if new_positions === nil do
        new_positions
      else
        Enum.reduce(@directions, new_positions, fn direction, new_positions ->
          {row, col} = new_pos = add(pos, direction)
          if new_positions && row in row_limit && col in col_limit do
            if MapSet.member?(filled, new_pos) or Map.has_key?(map, new_pos) do
              new_positions
            else
              MapSet.put(new_positions, new_pos)
            end
          else
            nil
          end
        end)
      end
    end)
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.to_charlist
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        case char do
          ?. -> []
          ?S -> [{position, :start}]
          ?| -> [{position, [{-1, 0}, {1, 0}]}]
          ?- -> [{position, [{0, -1}, {0, 1}]}]
          ?L -> [{position, [{-1, 0}, {0, 1}]}]
          ?J -> [{position, [{-1, 0}, {0, -1}]}]
          ?7 -> [{position, [{0, -1}, {1, 0}]}]
          ?F -> [{position, [{0,  1}, {1, 0}]}]
        end
      end)
    end)
    |> then(fn list ->
      start = Enum.find_value(list, fn {position, exits} ->
      case exits do
        :start ->
          position
        _ ->
          nil
      end
    end)
      {start, Enum.reject(list, fn {_, exits} -> exits === :start end)}
    end)
  end

  def print_grid(enclosed, map) do
    map = Enum.reduce(enclosed, map, fn position, map ->
      Map.put(map, position, :enclosed)
    end)
    print_grid(map)
    enclosed
  end

  def print_grid(map) do
    :io.nl
    {{min_row, _}, {max_row, _}} = Enum.min_max_by(Map.keys(map), &elem(&1, 0))
    {{_, min_col}, {_, max_col}} = Enum.min_max_by(Map.keys(map), &elem(&1, 1))
    Enum.each(min_row..max_row, fn row ->
      Enum.each(min_col..max_col, fn col ->
        position = {row, col}
        case map do
          %{^position => directions} ->
            chars = case directions do
                      [{-1, 0}, {1, 0}] -> "|"
                      [{0, -1}, {0, 1}] -> "-"
                      [{-1, 0}, {0, 1}] -> "L"
                      [{-1, 0}, {0, -1}] -> "J"
                      [{0, -1}, {1, 0}] -> "7"
                      [{0, 1},  {1, 0}] -> "F"
                      :enclosed -> IO.ANSI.bright() <> "I" <> IO.ANSI.reset()
                    end
            :io.put_chars(chars)
          %{} ->
            :io.put_chars(".")
        end
      end)
      :io.nl
    end)
    :io.nl
    map
  end
end
