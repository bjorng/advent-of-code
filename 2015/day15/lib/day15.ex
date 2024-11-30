defmodule Day15 do
  def part1(input) do
    parse(input)
    |> Enum.map(fn [a, b, c, d, _] ->
      [a, b, c, d]
    end)
    |> solve
  end

  def part2(input) do
    parse(input)
    |> solve
  end

  defp solve([i | _] = is) do
    init = List.duplicate(0, length(i))
    solve(is, init, 100, 0)
  end

  defp solve([i], current, amount, best) do
    current = mul_add(current, i, amount)
    |> Enum.map(&max(0, &1))

    case current do
      [a, b, c, d] ->
        max(best, a * b * c * d)
      [a, b, c, d, 500] ->
        max(best, a * b * c * d)
      _ ->
        best
    end
  end
  defp solve([_ | _], _current, -1, best), do: best
  defp solve([i | is], current, amount, best) do
    Enum.reduce(0..amount, best, fn this_amount, acc ->
      current = mul_add(current, i, this_amount)
      solve(is, current, amount - this_amount, acc)
    end)
  end

  defp mul_add([n | ns], [m | ms], amount) do
    [n + m * amount | mul_add(ns, ms, amount)]
  end
  defp mul_add([], [], _amount), do: []

  defp parse(input) do
    Enum.map(input, &String.split/1)
    |> Enum.map(fn [_, _, a, _, b, _, c, _, d, _, e] ->
      [a, b, c, d, e]
      |> Enum.map(&(String.trim(&1, ",")))
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
