defmodule Day05 do
  def part1(input) do
    {rules, updates} = parse(input)
    rules = init_rule_map(rules)

    updates
    |> Enum.filter(fn pages ->
      correct_order?(pages, rules)
    end)
    |> Enum.map(&middle/1)
    |> Enum.sum
  end

  def part2(input) do
    {rules, updates} = parse(input)
    rules = init_rule_map(rules)

    updates
    |> Enum.reject(fn pages ->
      correct_order?(pages, rules)
    end)
    |> Enum.map(fn pages ->
      order(pages, rules)
    end)
    |> Enum.map(&middle/1)
    |> Enum.sum
  end

  defp correct_order?([page | pages], rules) do
    rule = Map.fetch!(rules, page)
    Enum.all?(pages, &MapSet.member?(rule, &1)) and
    correct_order?(pages, rules)
  end
  defp correct_order?([], _), do: true

  defp middle(pages) do
    Enum.at(pages, div(length(pages), 2))
  end

  defp order([page | pages], rules) do
    rule = Map.fetch!(rules, page)
    case Enum.all?(pages, &MapSet.member?(rule, &1)) do
      true ->
        [page | order(pages, rules)]
      false ->
        order(insert(pages, page, rule), rules)
    end
  end
  defp order([], _), do: []

  defp insert([page | pages], other_page, rule) do
    case Enum.all?(pages, &MapSet.member?(rule, &1)) do
      true ->
        [page, other_page | pages]
      false ->
        [page | insert(pages, other_page, rule)]
    end
  end

  defp init_rule_map(rules) do
    Enum.reduce(rules, %{}, fn {j, k}, map ->
      map
      |> Map.update(j, MapSet.new([k]), fn succ -> MapSet.put(succ, k) end)
      |> Map.update(k, MapSet.new(), fn succ -> succ end)
    end)
  end

  defp parse(input) do
    [rules, updates] = String.split(input, "\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))

    rules = Enum.map(rules, fn rule ->
      String.split(rule, "|", trim: true)
      |> Enum.map(&String.to_integer(&1))
      |> List.to_tuple
    end)

    updates = Enum.map(updates, fn pages ->
      String.split(pages, ",", trim: true)
      |> Enum.map(&String.to_integer(&1))
    end)

    {rules, updates}
  end
end
