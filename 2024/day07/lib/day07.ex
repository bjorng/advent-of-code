defmodule Day07 do
  def part1(input) do
    solve(input, false)
  end

  def part2(input) do
    solve(input, true)
  end

  def solve(input, allow_concat) do
    parse(input)
    |> Enum.flat_map(fn {result, [n | ns]} ->
      if eval(n, ns, result, allow_concat) do
        [result]
      else
        []
      end
    end)
    |> Enum.sum
  end

  defp eval(a, [b | rest], result, allow_concat) do
    cond do
      eval(a + b, rest, result, allow_concat) ->
        true
      eval(a * b, rest, result, allow_concat) ->
        true
      true ->
        allow_concat and eval(concat(a, b), rest, result, allow_concat)
    end
  end
  defp eval(n, [], result, _), do: n === result

  defp concat(a, b) do
    shift(a, b) + b
  end

  defp shift(a, 0), do: a
  defp shift(a, b), do: shift(a * 10, div(b, 10))

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      {first, ": " <> rest} = Integer.parse(line)
      ints = String.split(rest, " ")
      |> Enum.map(&String.to_integer/1)
      {first, ints}
    end)
  end
end
