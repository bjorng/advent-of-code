defmodule Day05 do
  def part1(input) do
    Enum.count(input, &is_nice_part1?/1)
  end

  def part2(input) do
    Enum.count(input, &is_nice_part2?/1)
  end

  defp is_nice_part1?(string) do
    not String.contains?(string, ~w(ab cd pq xy)) and
    String.length(String.replace(string, ~r/[^aeiou]/, "")) >= 3 and
    String.match?(string, ~r/(.)\1/)
  end

  defp is_nice_part2?(string) do
    String.match?(string, ~r/(.).\1/) and
    has_pairs?(string)
  end

  defp has_pairs?(string) do
    string
    |> String.to_charlist
    |> collect_pairs
    |> Enum.frequencies
    |> Enum.find(fn {_, frequency} -> frequency >= 2 end)
  end

  defp collect_pairs(charlist) do
    case charlist do
      [c, c, c | tail] ->
        [[c, c] | collect_pairs([c | tail])]
      [c1, c2 | tail] ->
        [[c1, c2] | collect_pairs([c2 | tail])]
      [_] ->
        []
      [] ->
        []
    end
  end
end
