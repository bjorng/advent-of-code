defmodule Day14 do
  def part1(input) do
    {template, rules} = parse(input)
    rules = Map.new(rules)

    Stream.iterate(template, &(next_part1(&1, rules)))
    |> Stream.drop(10)
    |> Enum.take(1)
    |> hd
    |> Enum.frequencies
    |> Enum.min_max_by(fn {_, freq} -> freq end)
    |> result
  end

  def part2(input) do
    {template, rules} = parse(input)

    pairs = Enum.zip(template, tl(template))
    |> Enum.frequencies

    letters = Enum.frequencies(template)

    state = {pairs, letters}
    Stream.iterate(state, &(next_part2(&1, rules)))
    |> Stream.drop(40)
    |> Enum.take(1)
    |> hd
    |> elem(1)
    |> Enum.min_max_by(fn {_, freq} -> freq end)
    |> result
  end

  defp result({{_, min}, {_, max}}), do: max - min

  defp next_part1([e1, e2 | es], rules) do
    key = {e1, e2}
    case rules do
      %{^key => sub} ->
        [e1, sub | next_part1([e2 | es], rules)]
      %{} ->
        [e1 | next_part1([e2 | es], rules)]
    end
  end
  defp next_part1([_] = es, _), do: es

  defp next_part2({oldpairs, letters}, rules) do
    Enum.reduce(rules, {oldpairs, letters}, fn {{a, b}, c}, {pairs, letters} ->
      count = Map.get(oldpairs, {a, b}, 0)

      pairs = pairs
      |> Map.update({a, b}, -count, &(&1 - count))
      |> Map.update({a, c}, count, &(&1 + count))
      |> Map.update({c, b}, count, &(&1 + count))

      letters = Map.update(letters, c, count, &(&1 + count))

      {pairs, letters}
    end)
  end

  defp parse(input) do
    [template | input] = input
    template = String.codepoints(template)
    |> Enum.map(&String.to_atom/1)
    {template,
     Enum.map(input, fn line ->
       String.split(line, " -> ")
     end)
     |> Enum.map(fn transformation ->
       [[a, b], [c]] =
         Enum.map(transformation, fn string ->
           string
           |> String.codepoints
           |> Enum.map(&String.to_atom/1)
         end)
       {{a, b}, c}
     end)}
  end
end
