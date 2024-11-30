defmodule Day03 do
  use Bitwise

  def part1(input) do
    input = parse(input)
    num_samples = length(input)
    bits_per_sample = length(hd(input))

    gamma = input
    |> Enum.reduce(%{}, fn bits, acc ->
      bits
      |> Enum.with_index
      |> Enum.reduce(acc, fn {bit, index}, acc ->
        case bit do
          0 ->
            acc
          1 ->
            Map.update(acc, index, 1, &(&1 + 1))
        end
      end)
    end)
    |> Map.to_list
    |> Enum.sort
    |> Enum.reduce(0, fn {_, num_ones}, acc ->
      if num_ones > div(num_samples, 2) do
        acc * 2 + 1
      else
        acc * 2
      end
    end)

    epsilon = bnot(gamma) &&& ((1 <<< bits_per_sample) - 1)
    gamma * epsilon
  end

  def part2(input) do
    input = parse(input)

    oxygen = get_rating(input, :oxygen)
    co2 = get_rating(input, :co2)

    oxygen * co2
  end

  defp get_rating(samples, value) do
    get_rating(samples, 0, value)
  end

  defp get_rating([sample], _position, _value) do
    Enum.reduce(sample, 0, &(&2 * 2 + &1))
  end
  defp get_rating(samples, position, value) do
    map = Enum.group_by(samples, fn sample ->
      Enum.at(sample, position)
    end)
    zeroes = Map.get(map, 0)
    ones = Map.get(map, 1)
    samples = if length(ones) >= length(zeroes) do
      case value do
        :oxygen -> ones
        :co2 -> zeroes
      end
    else
      case value do
        :oxygen -> zeroes
        :co2 -> ones
      end
    end
    get_rating(samples, position + 1, value)
  end

  defp parse(input) do
    Enum.map(input, &to_charlist/1)
    |> Enum.map(fn line ->
      Enum.map(line, &(&1 - ?0))
    end)
  end
end
