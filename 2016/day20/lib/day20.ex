defmodule Day20 do
  use Bitwise
  def part1(input) do
    parse(input)
    |> merge_ranges
    |> find_lowest_ip
  end

  def part2(input) do
    parse(input)
    |> merge_ranges
    |> Enum.reduce(1 <<< 32, fn range, allowed ->
      allowed - (range.last - range.first + 1)
    end)
  end

  defp merge_ranges([]), do: []
  defp merge_ranges([r1, r2 | ranges]) do
    cond do
      r1.last + 1 === r2.first ->
        merge_ranges([r1.first..r2.last | ranges])
      r1.last in r2 ->
        merge_ranges([r1.first..r2.last | ranges])
      r1.last > r2.last ->
        merge_ranges([r1 | ranges])
      true ->
        [r1 | merge_ranges([r2 | ranges])]
    end
  end
  defp merge_ranges([range | ranges]) do
    [range | merge_ranges(ranges)]
  end

  defp find_lowest_ip([r1, r2 | ranges]) do
    if (r1.last + 1 < r2.first) do
      r1.last + 1
    else
      find_lowest_ip([r2 | ranges])
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [first, last] = String.split(line, "-")
      |> Enum.map(&String.to_integer/1)
      first..last
    end)
    |> Enum.sort
  end
end
