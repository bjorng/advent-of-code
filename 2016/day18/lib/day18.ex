defmodule Day18 do
  def part1(input, rows \\ 40) do
    solve(input, rows)
  end

  def part2(input) do
    rows = 400000
    solve(input, rows)
  end

  defp solve(input, rows) do
    input
    |> String.to_charlist
    |> Stream.iterate(&next_row/1)
    |> Stream.take(rows)
    |> Enum.reduce(0, fn row, sum ->
      sum + Enum.count(row, &(&1 === ?.))
    end)
  end

  defp next_row(row) do
    next_row(row, ?.)
  end

  defp next_row([center, right | tail], left) do
    [tile(left, center, right) | next_row([right | tail], center)]
  end
  defp next_row([center], left) do
    [tile(left, center, ?.)]
  end

  defp tile(?^, ?^, ?.), do: ?^
  defp tile(?., ?^, ?^), do: ?^
  defp tile(?^, ?., ?.), do: ?^
  defp tile(?., ?., ?^), do: ?^
  defp tile(_, _, _), do: ?.
end
