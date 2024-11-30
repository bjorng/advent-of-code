defmodule Day13 do
  def part1(lines) do
    parse(lines)
    |> Enum.reduce(0, fn {depth, range}, acc ->
      if rem(depth, (range - 1) * 2) == 0 do
	acc + depth * range
      else
	acc
      end
    end)
  end

  def part2(lines) do
    config = parse(lines)
    Stream.iterate(0, &(&1 + 1))
    |> Enum.find_index(&(not_caught?(config, &1)))
  end

  defp not_caught?(config, delay) do
    Enum.all?(config,
      fn {depth, range} ->
	rem(delay + depth, (range - 1) * 2) != 0
      end)
  end

  defp parse(lines) do
    Enum.map(lines, fn line ->
      {depth, ": " <> rest} = Integer.parse(line)
      {range, ""} = Integer.parse(rest)
      {depth, range}
    end)
  end
end
