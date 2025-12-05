defmodule Day05 do
  def part1(input) do
    {ranges, ingredients} = parse(input)
    Enum.count(ingredients, &in_any_range?(&1, ranges))
  end

  defp in_any_range?(ingredient, ranges) do
    Enum.any?(ranges, &(ingredient in &1))
  end

  def part2(input) do
    {ranges, _ingredients} = parse(input)
    ranges = ranges
    |> Enum.sort
    |> combine_ranges
    Enum.reduce(ranges, 0, &(Range.size(&1) + &2))
  end

  defp combine_ranges([r]), do: [r]
  defp combine_ranges([r1, r2 | rest]) do
    case Range.disjoint?(r1, r2) do
      true ->
        [r1 | combine_ranges([r2 | rest])]
      false ->
        r = min(r1.first, r2.first) .. max(r1.last, r2.last)
        combine_ranges([r | rest])
    end
  end

  defp parse([ranges, ingredients]) do
    ranges = Enum.map(ranges, fn range ->
      [first, last] = String.split(range, "-")
      String.to_integer(first) .. String.to_integer(last)
    end)
    ingredients = Enum.map(ingredients, &String.to_integer(&1))
    {ranges, ingredients}
  end
end
