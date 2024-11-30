defmodule Day05 do
  def part1(input) do
    parse(input)
    |> Enum.reduce(%{}, fn {first, second}, acc ->
      line_part1(first, second)
      |> Enum.reduce(acc, fn coordinate, acc ->
        Map.update(acc, coordinate, 1, &(&1 + 1))
      end)
    end)
    |> Enum.count(fn {_, value} -> value >= 2 end)
  end

  def part2(input) do
    parse(input)
    |> Enum.reduce(%{}, fn {first, second}, acc ->
      line_part2(first, second)
      |> Enum.reduce(acc, fn coordinate, acc ->
        Map.update(acc, coordinate, 1, &(&1 + 1))
      end)
    end)
    |> Enum.count(fn {_, value} -> value >= 2 end)
  end

  defp line_part1({x, y1}, {x, y2}) do
    Enum.map(y1..y2, &({x, &1}))
  end
  defp line_part1({x1, y}, {x2, y}) do
    Enum.map(x1..x2, &({&1, y}))
  end
  defp line_part1(_, _), do: []

  defp line_part2({x, y1}, {x, y2}) do
    Enum.map(y1..y2, &({x, &1}))
  end
  defp line_part2({x1, y}, {x2, y}) do
    Enum.map(x1..x2, &({&1, y}))
  end
  defp line_part2({x1, y1} = first, {x2, y2} = second) do
    x_inc = sign(x2 - x1)
    y_inc = sign(y2 - y1)
    diag_line(first, {x_inc, y_inc}, second)
  end

  defp diag_line(same, _, same), do: [same]
  defp diag_line({x1, y1}, {x_inc, y_inc} = inc, second) do
    [{x1, y1} | diag_line({x1 + x_inc, y1 + y_inc}, inc, second)]
  end

  defp sign(n) when n < 0, do: -1
  defp sign(n) when n > 0, do: 1

  defp parse(input) do
    Enum.map(input, fn line ->
      [first, "->", second] = String.split(line)
      {split_coordinate(first), split_coordinate(second)}
    end)
  end

  defp split_coordinate(coordinate) do
    String.split(coordinate, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end
