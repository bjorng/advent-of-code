defmodule Day16 do
  def part1(input) do
    grid = parse(input)
    position = {0, 0}
    direction = {0, 1}
    seen = MapSet.new
    energized = MapSet.new
    {_, energized} = move_beam(position, direction, seen, grid, energized)
    MapSet.size(energized)
  end

  def part2(input) do
    grid = parse(input)
    seen = MapSet.new
    energized = MapSet.new
    all_beams(grid)
    |> Task.async_stream(fn {position, direction} ->
      {_, energized} = move_beam(position, direction, seen, grid, energized)
      MapSet.size(energized)
    end, ordered: false)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.max
  end

  defp all_beams({{row_range, col_range}, _}) do
    max_row = row_range.last
    max_col = col_range.last
    vertical = Enum.flat_map(col_range, fn col ->
      [{{0, col}, {1, 0}}, {{max_row, col}, {-1, 0}}]
    end)
    horizontal = Enum.flat_map(row_range, fn row ->
      [{{row, 0}, {0, 1}}, {{row, max_col}, {0, -1}}]
    end)
    vertical ++ horizontal
  end

  defp move_beam(position, direction, seen, grid, energized) do
    case MapSet.member?(seen, {position, direction}) do
      true ->
        {seen, energized}
      false ->
        case get_grid(grid, position) do
          :outside ->
            {seen, energized}
          :empty ->
            energized = MapSet.put(energized, position)
            move_beam(add(position, direction), direction, seen, grid, energized)
          other ->
            seen = MapSet.put(seen, {position, direction})
            energized = MapSet.put(energized, position)
            get_beams(other, direction)
            |> Enum.reduce({seen, energized},fn beam, {seen, energized} ->
              move_beam(add(position, beam), beam, seen, grid, energized)
            end)
        end
    end
  end

  defp get_beams(what, direction) do
    case what do
      ?| ->
        case direction do
          {0, _} ->
            [{-1, 0}, {1, 0}]
          {_, 0} ->
            [direction]
        end
      ?- ->
        case direction do
          {0, _} ->
            [direction]
          {_, 0} ->
            [{0, -1}, {0, 1}]
        end
      ?/ ->
        case direction do
          {0, -1} -> [{1, 0}]
          {0, 1} ->  [{-1, 0}]
          {-1, 0} -> [{0, 1}]
          {1, 0} ->  [{0, -1}]
        end
      ?\\ ->
        case direction do
          {0, -1} -> [{-1, 0}]
          {0, 1} ->  [{1, 0}]
          {-1, 0} -> [{0, -1}]
          {1, 0} ->  [{0, 1}]
        end
    end
  end

  defp get_grid({{row_range, col_range}, grid}, {row, col} = position) do
    if row in row_range and col in col_range do
      Map.get(grid, position, :empty)
    else
      :outside
    end
  end

  defp add({row0, col0}, {row1, col1}) do
    {row0 + row1, col0 + col1}
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        case char do
          ?. -> []
          _ -> [{position, char}]
        end
      end)
    end)
    |> Map.new
    |> then(fn map ->
      {max_row, _} = Enum.max_by(Map.keys(map), &elem(&1, 0))
      {_, max_col} = Enum.max_by(Map.keys(map), &elem(&1, 1))
      {{0..max_row, 0..max_col}, map}
    end)
  end

  def print_grid({{row_range, col_range}, map} = grid, energized) do
    :io.nl
    Enum.each(row_range, fn row ->
      Enum.each(col_range, fn col ->
        position = {row, col}
        case MapSet.member?(energized, position) do
          true ->
            :io.put_chars("#")
          false ->
            case map do
              %{^position => item} ->
                :io.put_chars([item])
              %{} ->
                :io.put_chars(".")
            end
        end
      end)
      :io.nl
    end)
    :io.nl
    grid
  end
end
