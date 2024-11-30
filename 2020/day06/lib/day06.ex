defmodule Day06 do
  def part1(input) do
    parse(input)
    |> Enum.map(fn group ->
      group
      |> Enum.flat_map(&String.to_charlist/1)
      |> Enum.sort
      |> Enum.uniq
      |> Enum.count
    end)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn group ->
      group
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&MapSet.new/1)
      |> intersection
      |> MapSet.size
    end)
    |> Enum.sum
  end

  defp intersection([set | sets]) do
    Enum.reduce(sets, set, &MapSet.intersection/2)
  end

  defp parse(input) do
    input
    |> Enum.chunk_by(&(&1 === ""))
    |> Enum.reject(&(&1 == [""]))
  end
end
