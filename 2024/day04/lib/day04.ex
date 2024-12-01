defmodule Day04 do
  def part1(input) do
    parse(input)
    |> count_part1(~c"XMAS")
  end

  defp count_part1(grid, word) do
    Enum.reduce(grid, 0, fn {position, _}, n ->
      directions()
      |> Enum.reduce(n, fn direction, n ->
        case matches?(grid, word, position, direction) do
          true -> n + 1
          false -> n
        end
      end)
    end)
  end

  defp matches?(grid, [c|cs], position, direction) do
    case at(grid, position) do
      ^c ->
        position = add(position, direction)
        matches?(grid, cs, position, direction)
      _ ->
        false
    end
  end
  defp matches?(_, [], _, _), do: true

  defp directions do
    [{-1, -1}, {-1, 0}, {-1, 1},
     {0, -1}, {0, 1},
     {1, -1}, {1, 0}, {1, 1}]
  end

  def part2(input) do
    parse(input)
    |> count_part2
  end

  defp count_part2(grid) do
    Enum.reduce(grid, 0, fn {position, _}, n ->
      diagonals()
      |> Enum.reduce(n, fn direction, n ->
        b = matches_mas?(grid, position, direction) and
        matches_mas?(grid, position, rotate90(direction))
        case b do
          true -> n + 1
          false -> n
        end
      end)
    end)
  end

  defp diagonals do
    [{-1, -1}, {-1, 1},
     {1, -1}, {1, 1}]
  end

  defp matches_mas?(grid, position, direction) do
    at(grid, position) === ?A and
    at(grid, add(position, direction)) === ?M and
    at(grid, add(position, rotate180(direction))) === ?S
  end

  defp at(grid, position) do
    case grid do
      %{^position => c} -> c
      %{} -> nil
    end
  end

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp rotate90({a, b}), do: {b, -a}

  defp rotate180({a, b}), do: {-a, -b}

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
