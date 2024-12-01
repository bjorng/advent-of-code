defmodule Day13 do
  def part1(input) do
    parse(input)
    |> solve
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {a, b, target} ->
      offset = 10000000000000
      {a, b, add(target, {offset, offset})}
    end)
    |> solve
  end

  defp solve(input) do
    input
    |> Enum.map(&play/1)
    |> Enum.sum
  end

  defp play({{a0, a1}, {b0, b1}, {c0, c1}}) do
    # Solve the following equation system for integers:
    #
    #  a0 * x + b0 * y = c0
    #  a1 * x + b1 * y = c1
    #
    numerator = a0 * c1 - a1 * c0
    denominator = a0 * b1 - a1 * b0

    if rem(numerator, denominator) !== 0 do
      0
    else
      y = div(numerator, denominator)
      x = c1 - b1 * y
      if rem(x, a1) !== 0 do
        0
      else
        x = div(x, a1)
        3 * x + y
      end
    end
  end

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp parse(input) do
    input
    |> Enum.chunk_every(3)
    |> Enum.map(fn [a, b, p] ->
      {parse_button(a), parse_button(b), parse_prize(p)}
    end)
  end

  defp parse_button(line) do
    <<"Button ", _, ": ", rest::binary>> = line
    String.split(rest, ", ")
    |> Enum.map(fn <<_, s::binary>> ->
      String.to_integer(s)
    end)
    |> List.to_tuple
  end

  defp parse_prize(line) do
    "Prize: " <> rest = line
    String.split(rest, ", ")
    |> Enum.map(fn <<_, "=", s::binary>> ->
      String.to_integer(s)
    end)
    |> List.to_tuple
  end

end
