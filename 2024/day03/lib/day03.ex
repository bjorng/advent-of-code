defmodule Day03 do
  def part1(input) do
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/,
      input,
      [capture: :all_but_first])
    |> Enum.map(fn numbers ->
      [a, b] = Enum.map(numbers, &String.to_integer(&1))
      a * b
    end)
    |> Enum.sum
  end

  def part2(input) do
    Regex.scan(~r/(mul)\((\d{1,3}),(\d{1,3})\)|don't\(\)|do\(\)/,
                input)
    |> Enum.map(fn matched ->
      case matched do
        [_, "mul" | numbers]->
          [a, b] = Enum.map(numbers, &String.to_integer(&1))
          a * b
        ["don't()"] ->
          :disable
        ["do()"] ->
          :enable
      end
    end)
    |> then(&sum(&1, true, 0))
  end

  defp sum([:disable|tail], _, result) do
    sum(tail, false, result)
  end
  defp sum([:enable|tail], _, result) do
    sum(tail, true, result)
  end
  defp sum([number|tail], true, result) do
    sum(tail, true, result + number)
  end
  defp sum([_number|tail], false, result) do
    sum(tail, false, result)
  end
  defp sum([], _, result), do: result
end
