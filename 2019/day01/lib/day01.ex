defmodule Day01 do
  def part1(input) do
    input
    |> Stream.map(fn line ->
      {int, ""} = Integer.parse(line)
      int
    end)
    |> Stream.map(&fuel/1)
    |> Enum.sum
  end

  def part2(input) do
    input
    |> Stream.map(fn line ->
      {int, ""} = Integer.parse(line)
      int
    end)
    |> Stream.map(&total_fuel/1)
    |> Enum.sum
  end

  defp total_fuel(mass) do
    case fuel(mass) do
      needed when needed > 0 ->
	needed + total_fuel(needed)
      _ ->
	0
    end
  end

  defp fuel(mass) do
    div(mass, 3) - 2
  end
end
