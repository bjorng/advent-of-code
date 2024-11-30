defmodule Day13 do
  def part1(input) do
    rules = parse(input)
    people = people(rules)
    rules = rule_map(rules)
    solve(people, rules)
  end

  def part2(input) do
    rules = parse(input)
    people = people(rules)

    rules = Enum.flat_map(people, fn person ->
      [{"myself", person, 0}, {person, "myself", 0}]
    end) ++ rules
    people = people(rules)
    rules = rule_map(rules)

    solve(people, rules)
  end

  defp solve(people, rules) do
    people
    |> permutations
    |> Enum.map(&(points(&1, rules)))
    |> Enum.max
  end

  defp people(rules) do
    rules
    |> Enum.map(&elem(&1, 1))
    |> Enum.uniq
  end

  defp rule_map(rules) do
    rules
    |> Enum.map(fn {name1, name2, units} -> {{name1, name2}, units} end)
    |> Map.new
  end

  defp points(people, rules) do
    [name1, name2 | _] = people
    points(people ++ [name1, name2], rules, 0)
  end

  defp points([left, name, right | tail], rules, acc) do
    acc = acc + Map.fetch!(rules, {name,left}) + Map.fetch!(rules, {name,right})
    points([name, right | tail], rules, acc)
  end
  defp points(_, _, acc), do: acc

  def permutations([]), do: [[]]
  def permutations(list) do
    for elem <- list,
      rest <- permutations(list--[elem]) do
        [elem|rest]
    end
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      case String.split(line) do
        [name, "would", "gain" | tail] ->
          parse_rest(tail, name, 1)
        [name, "would", "lose" | tail] ->
          parse_rest(tail, name, -1)
      end
    end)
  end

  defp parse_rest([units, "happiness", "units", "by",
                   "sitting", "next", "to", other_name],
    name, sign) do
    {name, String.trim(other_name, "."), sign * String.to_integer(units)}
  end
end
