defmodule Day06 do
  def part1(input, days) do
    parse(input)
    |> prepare
    |> consolidate
    |> Stream.iterate(&next/1)
    |> Stream.drop(days)
    |> Enum.take(1)
    |> hd
    |> Enum.reduce(0, &(elem(&1, 1) + &2))
  end

  def part2(input, days) do
    part1(input, days)
  end

  defp prepare(fish) do
    Enum.map(fish, &({&1, 1}))
  end

  defp next(fish) do
    {fish, new} = Enum.map_reduce(fish, 0, fn {timer, n}, acc ->
      if timer == 0 do
        {{6, n}, acc + n}
      else
        {{timer - 1, n}, acc}
      end
    end)
    [{8, new} | fish]
    |> consolidate
  end

  defp consolidate(fish) do
    Enum.group_by(fish, &(elem(&1, 0)))
    |> Enum.map(fn {timer, counts} ->
      sum = Enum.map(counts, &(elem(&1, 1)))
      |> Enum.sum
      {timer, sum}
    end)
  end

  defp parse(input) do
    String.split(hd(input), ",")
    |> Enum.map(&String.to_integer/1)
  end
end
