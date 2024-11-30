defmodule Day15 do
  def part1(input) do
    parse(input)
    |> solve
  end

  def part2(input) do
    input = parse(input)
    next_disc = length(input) + 1

    input
    |> Kernel.++([{next_disc, 11, 0}])
    |> solve
  end

  defp solve(discs), do: solve(discs, 0, 1)

  defp solve([], time, _step), do: time
  defp solve([{offset, positions, start} | discs], time, step) do
    time = Stream.iterate(time, &(&1 + step))
    |> Enum.find(fn time -> rem(time + start + offset, positions) === 0 end)
    solve(discs, time, step * positions)
  end

  defp parse(input) do
    re = ~r/^Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)[.]$/
    input
    |> Enum.map(fn line ->
      Regex.run(re, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
  end
end
