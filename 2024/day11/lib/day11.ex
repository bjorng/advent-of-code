defmodule Day11 do
  def part1(input, blinks \\ 25) do
    solve(input, blinks)
  end

  def part2(input, blinks \\ 75) do
    solve(input, blinks)
  end

  defp solve(input, blinks) do
    parse(input)
    |> blink_stones(blinks, 0, %{}, 0)
    |> then(&elem(&1, 0))
  end

  defp blink_stones(stones, blinks, turn, cache, acc) do
    Enum.reduce(stones, {acc, cache}, fn stone, {acc, cache} ->
      {result, cache} = blink_stone(stone, blinks, turn, cache)
      cache = Map.put(cache, {turn, stone}, result)
      {acc + result, cache}
    end)
  end

  defp blink_stone(_, 0, _, cache), do: {1, cache}
  defp blink_stone(stone, blinks, turn, cache) do
    key = {turn, stone}
    case cache do
      %{^key => result} ->
        {result, cache}
      %{} ->
        if stone === 0 do
          [1]
        else
          n = num_digits(stone)
          if rem(n, 2) === 0 do
            d = 10 ** div(n, 2)
            [div(stone, d), rem(stone, d)]
          else
            [stone * 2024]
          end
        end
        |> blink_stones(blinks - 1, turn + 1, cache, 0)
    end
  end

  defp num_digits(stone) do
    num_digits(stone, 1)
  end

  defp num_digits(stone, n) do
    case div(stone, 10) do
      0 -> n
      stone -> num_digits(stone, n + 1)
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
    |> hd
  end
end
