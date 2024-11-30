defmodule Day02 do
  def part1(lines) do
    parse_input(lines)
    |> Stream.map(fn numbers ->
      {min, max} = Enum.min_max(numbers)
      max - min
    end)
    |> Enum.sum
  end

  def part2(lines) do
    parse_input(lines)
    |> Stream.map(&divide_divisable/1)
    |> Enum.sum
  end

  def divide_divisable([number | numbers]) do
    divide_divisable(number, numbers) || divide_divisable(numbers)
  end

  def divide_divisable(number, numbers) do
    Enum.reduce_while(numbers, nil, fn other, _acc ->
      {min, max} = Enum.min_max([number, other])
      result = div(max, min)
      if (result * min == max), do: {:halt, result}, else: {:cont, nil}
    end)
  end

  defp parse_input(lines) do
    Enum.map(lines, &parse_line/1)
  end

  defp parse_line(line) do
    String.split(line, [" ", "\t"])
    |> Enum.map(&String.to_integer/1)
  end
end
