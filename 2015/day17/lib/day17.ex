defmodule Day17 do
  def part1(input, liters \\ 150) do
    parse(input)
    |> combinations
    |> Enum.count(&(Enum.sum(&1) === liters))
  end

  def part2(input, liters \\ 150) do
    parse(input)
    |> combinations
    |> Enum.filter(&(Enum.sum(&1) === liters))
    |> Enum.group_by(&(length(&1)))
    |> Map.to_list
    |> Enum.min
    |> elem(1)
    |> length
  end

  defp combinations([head | tail]) do
    cs = combinations(tail)
    for c <- cs do [head | c] end ++ cs
  end
  defp combinations([]), do: [[]]

  defp parse(input) do
    Enum.map(input, &String.to_integer/1)
  end
end
