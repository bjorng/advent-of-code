defmodule Day04 do
  def part1(input) do
    parse(input)
    |> Enum.count(&one_fully_contained/1)
  end

  defp one_fully_contained({range1, range2}) do
    fully_contains(range1, range2) or fully_contains(range2, range1)
  end

  defp fully_contains(first..last, range) do
    first in range and last in range
  end

  def part2(input) do
    parse(input)
    |> Enum.count(&any_overlap/1)
  end

  defp any_overlap({range1, range2}) do
    not Range.disjoint?(range1, range2)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn range ->
        [first, last] = range
        |> String.split("-")
        |> Enum.map(&String.to_integer/1)
        first..last
      end)
      |> List.to_tuple
    end)
  end
end
