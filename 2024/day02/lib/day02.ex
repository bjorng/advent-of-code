defmodule Day02 do
  def part1(input) do
    parse(input)
    |> Enum.count(fn levels ->
      is_safe(levels)
    end)
  end

  def part2(input) do
    parse(input)
    |> Enum.count(fn levels ->
      damp(levels, [])
    end)
  end

  defp damp([level | levels], prefix) do
    is_safe(Enum.reverse(prefix, levels)) or
    damp(levels, [level | prefix])
  end
  defp damp([], prefix) do
    is_safe(prefix)
  end

  defp is_safe([a, a | _]), do: false
  defp is_safe([a, b | _] = levels) do
    diff = a - b
    is_safe(levels, div(diff, abs(diff)))
  end

  defp is_safe(levels, sign) do
    Enum.chunk_every(levels, 2, 1)
    |> Enum.all?(fn chunks ->
      case chunks do
        [a, b] ->
          sign * (a - b) in 1..3
        [_] ->
          true
      end
    end)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, " ")
      |> Enum.map(&String.to_integer(&1))
    end)
  end
end
