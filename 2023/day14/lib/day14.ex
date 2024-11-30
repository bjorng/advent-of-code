defmodule Day14 do
  @cycles 1000000000

  def part1(input) do
    parse(input)
    |> tilt({-1, 0})
    |> load
  end

  defp load({{row_range, _}, dish}) do
    max_load = row_range.last + 1
    Enum.reduce(dish, 0, fn {{row, _}, item}, sum ->
      if item !== :round do
        sum
      else
        sum + max_load - row
      end
    end)
  end

  def part2(input) do
    input = parse(input)
    seen = %{}
    cycle(input, 0, @cycles, seen)
    |> load
  end

  defp cycle(dish, last, last, _seen), do: dish
  defp cycle(dish, n, last, seen) do
    dish = one_cycle(dish)
    case seen do
      %{^dish => num} ->
        period = n - num
        n = n + period * div(last - n, period)
        cycle(dish, n + 1, last, seen)
      %{} ->
        cycle(dish, n + 1, last, Map.put(seen, dish, n))
    end
  end

  defp one_cycle(dish) do
    [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]
    |> Enum.reduce(dish, fn direction, dish ->
      tilt(dish, direction)
    end)
  end

  defp tilt({{row_range, col_range} = ranges, dish}, direction) do
    {ranges, tilt(dish, row_range, col_range, direction)}
  end

  defp tilt(dish, row_range, col_range, direction) do
    case tilt_one_step(dish, row_range, col_range, direction) do
      ^dish -> dish
      dish -> tilt(dish, row_range, col_range, direction)
    end
  end

  defp tilt_one_step(dish, row_range, col_range, direction) do
    Enum.reduce(dish, dish, fn {position, what}, dish ->
      if what !== :round do
        dish
      else
        {row, col} = add(position, direction)
        if row in row_range and col in col_range do
          new_position = {row, col}
          case dish do
            %{^new_position => _} ->
              dish
            %{} ->
              Map.delete(dish, position)
              |> Map.put(new_position, :round)
          end
        else
          dish
        end
      end
    end)
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
          ?O -> [{position, :round}]
          ?\# -> [{position, :cube}]
          ?. -> []
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

  def print_grid({{row_range, col_range}, map} = grid) do
    :io.nl
    Enum.each(row_range, fn row ->
      Enum.each(col_range, fn col ->
        position = {row, col}
        case map do
          %{^position => item} ->
            chars = case item do
                      :round -> "O"
                      :cube -> "#"
                    end
            :io.put_chars(chars)
          %{} ->
            :io.put_chars(".")
        end
      end)
      :io.nl
    end)
    :io.nl
    grid
  end
end
