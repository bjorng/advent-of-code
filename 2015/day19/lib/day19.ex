defmodule Day19 do
  def part1(input) do
    {rules, molecule} = parse(input)

    rules = prepare_rules(rules)

    molecule = split_molecule(molecule)

    replace(molecule, rules)
    |> Enum.uniq
    |> Enum.count
  end

  # Based on askalski's Perl solution; fourth from top in this thread:
  #
  # https://www.reddit.com/r/adventofcode/comments/3xflz8/day_19_solutions/?utm_medium=android_app&utm_source=share
  #
  # His formula (top post in the thread) does not work on my input, but his
  # Perl implementation does.

  def part2(input) do
    {rules, molecule} = parse(input)

    molecule = String.reverse(molecule)

    rules = rules
    |> Enum.map(fn {pat, repl} ->
      {String.reverse(repl), String.reverse(pat)}
    end)

    regex = Enum.map(rules, fn {pat, _} -> pat end)
    |> Enum.intersperse("|")
    |> to_string

    {:ok, regex} = Regex.compile(regex)

    rules = Map.new(rules)

    Stream.iterate(molecule, &(next_molecule(&1, regex, rules)))
    |> Stream.with_index
    |> Stream.drop_while(fn {molecule, _} -> molecule != "e" end)
    |> Enum.take(1)
    |> hd
    |> elem(1)
  end

  defp next_molecule(molecule, regex, rules) do
    Regex.replace(regex, molecule, &(Map.fetch!(rules, &1)), [global: false])
  end

  defp prepare_rules(rules) do
    rules
    |> Enum.map(fn {element, replacement} ->
      {String.to_atom(element), split_molecule(replacement)}
    end)
    |> Enum.group_by(&(elem(&1, 0)), &(elem(&1, 1)))
  end

  defp split_molecule(molecule) do
    Regex.scan(~r/([A-Z][a-z]?)/, molecule, [capture: :all_but_first])
    |> Enum.concat
    |> Enum.map(&String.to_atom/1)
  end

  defp replace(molecule, rules) do
    replace(molecule, rules, [], [])
  end

  defp replace([e | es], rules, reversed, all) do
    case rules do
      %{^e => replacements} ->
        all =
          Enum.reduce(replacements, all, fn repl, acc ->
            [Enum.reverse(reversed, repl ++ es) | acc]
          end)
        replace(es, rules, [e | reversed], all)
      %{} ->
        replace(es, rules, [e | reversed], all)
    end
  end
  defp replace([], _, _, all), do: all

  defp parse(input) do
    {rules,[string]} = Enum.split(input, -1)
    rules = Enum.map(rules, fn line ->
      [pattern, "=>", replacement] = String.split(line)
      {pattern, replacement}
    end)
    {rules, string}
  end
end
