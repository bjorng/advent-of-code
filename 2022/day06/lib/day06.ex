defmodule Day06 do
  def part1(input) do
    parse(input)
    |> solve(4)
  end

  def part2(input) do
    parse(input)
    |> solve(14)
  end

  defp solve(list, num_uniq) do
    solve(list, num_uniq, 1)
  end

  defp solve(list, num_uniq, index) do
    chars = Enum.take(list, num_uniq)
    |> Enum.uniq
    |> length
    if chars === num_uniq do
      index + num_uniq - 1
    else
      solve(tl(list), num_uniq, index + 1)
    end
  end

  defp parse(input) do
    input
    |> String.to_charlist
  end
end
