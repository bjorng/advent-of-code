defmodule Day01 do
  def part1(input) do
    numbers = Enum.map(input, &String.to_integer/1)
    set = MapSet.new(numbers)
    find_sum(numbers, set, 2020)
  end

  def part2(input) do
    numbers = Enum.map(input, &String.to_integer/1)
    set = MapSet.new(numbers)
    Enum.find_value(numbers, fn n ->
      other = 2020 - n
      case find_sum(numbers, set, other) do
        product when is_integer(product) ->
          product * n
        nil ->
          nil
      end
    end)
  end

  defp find_sum(numbers, set, desired_sum) do
    Enum.find_value(numbers, fn n ->
      other = desired_sum - n
      if other in set do
        n * other
      end
    end)
  end
end
