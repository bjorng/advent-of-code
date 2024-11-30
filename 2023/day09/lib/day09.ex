defmodule Day09 do
  def part1(input) do
    parse(input)
    |> Enum.map(&extrapolate/1)
    |> Enum.sum
  end

  defp extrapolate(numbers) do
    diffs = differences(numbers)
    case Enum.all?(diffs, &(&1 === 0)) do
      true ->
        List.last(numbers)
      false ->
        List.last(numbers) + extrapolate(diffs)
    end
  end

  def part2(input) do
    parse(input)
    |> Enum.map(&extrapolate_part2/1)
    |> Enum.sum
  end

  defp extrapolate_part2(numbers) do
    diffs = differences(numbers)
    case Enum.all?(diffs, &(&1 === 0)) do
      true ->
        hd(numbers)
      false ->
        hd(numbers) - extrapolate_part2(diffs)
    end
  end

  defp differences([n1, n2 | rest]) do
    [n2 - n1 | differences([n2 | rest])]
  end
  defp differences([_]), do: []

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, " ")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
