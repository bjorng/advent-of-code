defmodule Day20 do
  def part1(input) do
    solve(input, &next_house_part1/1)
  end

  def part2(input) do
    solve(input, &next_house_part2/1)
  end

  def presents_part1(house) do
    factor_sum(house) * 10
  end

  def presents_part2(house) do
    sum = factors(house)
    |> Enum.filter(&(div(house, &1) <= 50))
    |> Enum.sum
    sum * 11
  end

  defp solve(input, next_house) do
    Stream.unfold(1, next_house)
    |> Stream.drop_while(fn {_, presents} -> presents < input end)
    |> Enum.take(1)
    |> hd
    |> elem(0)
  end

  defp next_house_part1(house) do
    {{house, presents_part1(house)}, house + 1}
  end

  defp next_house_part2(house) do
    {{house, presents_part2(house)}, house + 1}
  end

  def factor_sum(n) do
    factors(n)
    |> Enum.sum
  end

  def factors(1), do: [1]
  def factors(n) do
    {n, acc} = two_factors(n, [])
    factors(n, 3, acc)
    |> combinations
    |> Enum.map(fn fs ->
      Enum.reduce(fs, 1, &(&1 * &2))
    end)
    |> Enum.sort
    |> Enum.dedup
  end

  defp factors(1, _, acc), do: acc
  defp factors(n, n, acc), do: [n | acc]
  defp factors(n, p, acc) when p * p <= n do
    if rem(n, p) === 0 do
      factors(div(n, p), p, [p | acc])
    else
      factors(n, p + 2, acc)
    end
  end
  defp factors(n, _, acc), do: [n | acc]

  defp two_factors(1, acc), do: {1, acc}
  defp two_factors(n, acc) do
    if rem(n, 2) === 0 do
      two_factors(div(n, 2), [2 | acc])
    else
      {n, acc}
    end
  end

  defp combinations([head | tail]) do
    cs = combinations(tail)
    for c <- cs do [head | c] end ++ cs
  end
  defp combinations([]), do: [[]]
end
