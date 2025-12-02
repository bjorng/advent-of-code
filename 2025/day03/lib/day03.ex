defmodule Day03 do
  def part1(input) do
    solve(input, 2)
  end

  def part2(input) do
    solve(input, 12)
  end

  defp solve(input, num_batteries) do
    parse(input)
    |> Enum.map(fn bank ->
      power = Integer.pow(10, num_batteries-1)
      {result, _} = find_max(bank, power, %{})
      result
    end)
    |> Enum.sum
  end

  defp find_max(_, 0, memo), do: {0, memo}
  defp find_max([], _mul, memo), do: {-10_000_000_000_000, memo}
  defp find_max([j | rest], mul, memo) do
    {amount1, memo} = memo_find_max(rest, div(mul, 10), memo)
    amount1 = j * mul + amount1
    {amount2, memo} = memo_find_max(rest, mul, memo)
    {max(amount1, amount2), memo}
  end

  defp memo_find_max(rest, mul, memo) do
    key = {mul,rest}
    case memo do
      %{^key => result} ->
        {result, memo}
      %{} ->
        {result, memo} = find_max(rest, mul, memo)
        memo = Map.put(memo, key, result)
        {result, memo}
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.to_charlist(line)
      |> Enum.map(&(&1 - ?0))
    end)
  end
end
