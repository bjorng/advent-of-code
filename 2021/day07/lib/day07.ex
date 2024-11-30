defmodule Day07 do
  def part1(input) do
    solve(input, &(&1))
  end

  def part2(input) do
    solve(input, &(div(&1 * (&1 + 1), 2)))
  end

  defp solve(input, fuel_needed) do
    crabs = parse(input)
    {min,max} = Enum.min_max(crabs)

    Enum.map(min..max, fn position ->
      align_crabs(position, crabs, fuel_needed)
    end)
    |> Enum.min
  end

  defp align_crabs(position, crabs, fuel_needed) do
    Enum.reduce(crabs, 0, fn current, fuel ->
      fuel + fuel_needed.(abs(current - position))
    end)
  end

  defp parse(input) do
    hd(input)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
