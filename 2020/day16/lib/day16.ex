defmodule Day16 do
  def part1(input) do
    {rules, _, nearby} = parse(input)
    rules = flatten_rules(rules)
    nearby
    |> List.flatten()
    |> Enum.filter(fn field ->
      not valid_field?(field, rules)
    end)
    |> Enum.sum
  end

  def part2(input) do
    {rules, yours, nearby} = parse(input)
    nearby = discard_invalid_tickets(rules, nearby)
    all_tickets = [yours | nearby]

    # Figure out the zero-based index for each field.
    {indices,_} = rules
    |> Enum.map(fn {name, rules} ->
      {name, find_index_candidates(rules, all_tickets)}
    end)
    |> Enum.sort_by(fn {_name, set} -> MapSet.size(set) end)
    |> Enum.map_reduce(MapSet.new(), fn {name, candidates}, seen ->
      [index] = MapSet.difference(candidates, seen)
      |> MapSet.to_list()
      {{name, index}, MapSet.put(seen, index)}
    end)

    # Retrieve the values for the departure fields and multiply them.
    indices
    |> Enum.filter(fn {name, _index} ->
      String.starts_with?(name, "departure")
    end)
    |> Enum.map(fn {_, index} ->
      Enum.at(yours, index)
    end)
    |> Enum.reduce(1, &*/2)
  end

  defp find_index_candidates(rules, tickets) do
    candidates = MapSet.new(0..length(hd(tickets))-1)
    Enum.reduce(tickets, candidates, fn ticket, acc ->
      Enum.with_index(ticket)
      |> Enum.reduce(acc, fn {field, index}, acc ->
        case valid_field?(field, rules) do
          true -> acc
          false -> MapSet.delete(acc, index)
        end
      end)
    end)
  end

  defp discard_invalid_tickets(rules, nearby) do
    rules = flatten_rules(rules)
    Enum.filter(nearby, fn ticket -> valid?(ticket, rules) end)
  end

  defp valid?(ticket, rules) do
    Enum.all?(ticket, fn field ->
      valid_field?(field, rules)
    end)
  end

  defp valid_field?(field, rules) do
    Enum.any?(rules, fn range ->
      field in range
    end)
  end

  defp flatten_rules(rules) do
    Enum.flat_map(rules, &(elem(&1, 1)))
  end

  defp parse(input) do
    {first, next} = Enum.split_while(input, fn line ->
      line != "your ticket:"
    end)
    {yours, nearby} = Enum.split_while(next, fn line ->
      line != "nearby tickets:"
    end)

    rules = TicketParser.parse_rules(first)
    yours = parse_ticket(hd(tl(yours)))
    nearby = Enum.map(tl(nearby), &parse_ticket/1)
    {rules, yours, nearby}
  end

  defp parse_ticket(fields) do
    String.split(fields, ",") |> Enum.map(&String.to_integer/1)
  end
end

defmodule TicketParser do
  import NimbleParsec

  defp reduce_range([min, max]) do
    min..max
  end

  defp reduce_rule([description, range1, range2]) do
    {description, [range1, range2]}
  end

  range = integer(min: 1)
  |> ignore(string("-"))
  |> integer(min: 1)
  |> reduce({:reduce_range, []})

  rule_def = ascii_string([?a..?z,?\s], min: 1)
  |> ignore(string(": "))
  |> concat(range)
  |> ignore(string(" or "))
  |> concat(range)
  |> eos()
  |> reduce({:reduce_rule, []})

  defparsecp :rule, rule_def

  def parse_rules(input) do
    Enum.map(input, fn(line) ->
      {:ok, [res], _, _, _, _} = rule(line)
      res
    end)
  end
end
