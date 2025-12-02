defmodule Day02 do
  def part1(input) do
    solve(input, &invalid_part1?/1)
  end

  defp invalid_part1?(n) when is_integer(n) and n > 0 do
    cond do
      n in 10..99 ->
        div(n, 10) === rem(n, 10)
      n in 1000..9999 ->
        div(n, 100) === rem(n, 100)
      n in 100_000..999_999 ->
        div(n, 1000) === rem(n, 1000)
      n in 10_000_000..99_999_999 ->
        div(n, 10_000) === rem(n, 10_000)
      n in 1_000_000_000..9_999_999_999 ->
        div(n, 100_000) === rem(n, 100_000)
      true -> false
    end
  end

  def part2(input) do
    solve(input, &invalid_part2?/1)
  end

  defp invalid_part2?(n) when is_integer(n) and n > 0 do
    powers = [10, 100, 1000, 10000, 100000, 1000000]
    Enum.any?(powers, fn power ->
      part = rem(n, power)
      if part < div(power, 10) do
        false
      else
        case count_parts(div(n, power), power, part, 1) do
          nil -> false
          num_parts -> num_parts >= 2
        end
      end
    end)
  end

  defp count_parts(0, _power, _part, num_parts), do: num_parts
  defp count_parts(n, power, part, num_parts) do
    case rem(n, power) do
      ^part ->
        count_parts(div(n, power), power, part, num_parts + 1)
      _ ->
        nil
    end
  end

  defp solve(input, invalid) do
    parse(input)
    |> Enum.flat_map(&expand_range(&1, invalid))
    |> Enum.sum
  end

  defp expand_range(r, invalid) do
    Enum.flat_map(r, fn n ->
      case invalid.(n) do
        true -> [n]
        false -> []
      end
    end)
  end

  defp parse(input) do
    input
    |> Enum.flat_map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn range ->
        range
        |> String.split("-")
        |> then(fn [first, last] ->
          String.to_integer(first) .. String.to_integer(last)
        end)
      end)
    end)
  end
end
