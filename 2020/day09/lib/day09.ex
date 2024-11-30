defmodule Day09 do
  def part1(input, preamble \\ 25) do
    input = parse(input)
    |> Enum.with_index

    index_to_num = input
    |> Enum.map(fn {number, index} -> {index, number} end)
    |> Map.new

    input
    |> Enum.drop(preamble)
    |> Enum.find_value(input, fn {desired_sum, index} ->
      range = index-preamble .. index-1
      is_sum = Enum.any?(range, fn prev_index ->
        prev_num = Map.get(index_to_num, prev_index)
        other = desired_sum - prev_num
        Enum.any?(range, fn other_index ->
          Map.get(index_to_num, other_index) === other
        end)
      end)
      if not is_sum, do: desired_sum
    end)
  end

  def part2(input, preamble \\ 25) do
    desired_sum = part1(input, preamble)
    input = parse(input)

    find_contiguous_set(input, desired_sum)
  end

  defp find_contiguous_set(input, desired_sum) do
    case find_anchored_sum(input, desired_sum) do
      nil ->
        find_contiguous_set(tl(input), desired_sum)
      remaining ->
        num_numbers = length(input) - length(remaining)
        {min, max} = Enum.take(input, num_numbers)
        |> Enum.min_max
        min + max
    end
  end

  defp find_anchored_sum([desired_sum | numbers], desired_sum) do
    numbers
  end
  defp find_anchored_sum([number | numbers], desired_sum) do
    if desired_sum < number do
      nil
    else
      find_anchored_sum(numbers, desired_sum - number)
    end
  end

  defp parse(input) do
    Enum.map(input, &String.to_integer/1)
  end
end
