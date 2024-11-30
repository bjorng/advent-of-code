defmodule Day02 do
  def part1(input) do
    parse(input)
    |> Enum.map(fn {l, w, h} ->
      areas = [l*w, w*h, h*l]
      extra = Enum.min(areas)
      2 * Enum.sum(areas) + extra
    end)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {l, w, h} ->
      dimensions = [l, w, h]
      [d1, d2, _] = Enum.sort(dimensions)
      2 * (d1 + d2) + l * w * h
    end)
    |> Enum.sum
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      String.split(line, "x")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
  end
end
