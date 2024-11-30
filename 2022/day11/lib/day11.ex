defmodule Day11 do
  def part1(input) do
    monkeys = parse(input)
    solve(monkeys, 20, &(div(&1, 3)))
  end

  def part2(input) do
    monkeys = parse(input)
    n = monkeys
    |> Enum.map(fn {_, {_, _, {div, _, _}}} -> div end)
    |> Enum.product
    solve(monkeys, 10_000, &(rem(&1, n)))
  end

  defp solve(monkeys, rounds, stress_reduction) do
    Enum.reduce(1..rounds, monkeys,
      fn _, monkeys ->
        one_round(monkeys, stress_reduction)
      end)
    |> Enum.filter(fn
      {{:inspections, _}, _count} -> true
      {_, _} -> false
    end)
    |> Enum.map(fn {{_,_}, count} -> count end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product
  end

  defp one_round(monkeys, stress_reduction) do
    Enum.reduce(0..(map_size(monkeys)-1), monkeys,
      fn id, monkeys ->
        case monkeys do
          %{^id => {items, operation, test}} ->
            monkeys =
              Enum.reduce(items, monkeys,
                fn level, monkeys ->
                  one_item(level, operation, test, stress_reduction, monkeys)
                end)
            num_items = length(items)
            Map.put(monkeys, id, {[], operation, test})
            |> Map.update({:inspections, id}, num_items, &(&1 + num_items))
          %{} ->
            monkeys
        end
      end)
  end

  defp one_item(level, operation, test, stress_reduction, monkeys) do
    level = evaluate(operation, level)
    level = stress_reduction.(level)
    {n, true_monkey, false_monkey} = test
    recipient = if rem(level, n) === 0 do
      true_monkey
    else
      false_monkey
    end
    throw_item(recipient, level, monkeys)
  end

  defp evaluate({op, a, b}, old) do
    a = if a == :old, do: old, else: a
    b = if b == :old, do: old, else: b
    apply(:erlang, op, [a, b])
  end

  defp throw_item(recipient, level, monkeys) do
    {items, operation, test} = Map.get(monkeys, recipient)
    items = items ++ [level]
    Map.put(monkeys, recipient, {items, operation, test})
  end

  defp parse(input) do
    {:ok, result, "", _, _, _} = MonkeyParser.monkeys(input)
    Map.new(result)
  end
end

defmodule MonkeyParser do
  import NimbleParsec

  defp atomify([string]), do: String.to_atom(string)
  defp tuplify([a,b], tag), do: {tag, a, b}
  defp wrap_operation([a,op,b]), do: {op, a, b}

  defp wrap_test([d, {:if, true, true_monkey},
                  {:if, false, false_monkey}]) do
    {d, true_monkey, false_monkey}
  end

  defp wrap_monkey([id, items, operation, test]) do
    {id, {items, operation, test}}
  end

  spaces = ignore(ascii_string([?\s,?\n], min: 1))
  comma = ignore(string(","))
  colon = ignore(string(":"))

  number_comma =
    integer(min: 1)
    |> optional(comma)
    |> concat(spaces)

  number_list =
    repeat(number_comma)

  starting_items =
    ignore(string("Starting items: "))
    |> concat(number_list)
    |> wrap

  old =
    string("old")
    |> reduce({:atomify, []})

  operand = choice([integer(min: 1), old])

  operator =
    ascii_string([?+, ?-, ?*, ?/], min: 1)
    |> reduce({:atomify, []})

  operation =
    ignore(string("Operation: new ="))
    |> concat(spaces)
    |> concat(operand)
    |> concat(spaces)
    |> concat(operator)
    |> concat(spaces)
    |> concat(operand)
    |> reduce({:wrap_operation, []})

  bool =
    choice([string("true"), string("false")])
    |> reduce({:atomify, []})

  if_clause =
    ignore(string("If "))
    |> concat(bool)
    |> concat(colon)
    |> ignore(string(" throw to monkey "))
    |> integer(1)
    |> reduce({:tuplify, [:if]})

  test =
    ignore(string("Test: divisible by "))
    |> integer(min: 1)
    |> concat(spaces)
    |> concat(if_clause)
    |> concat(spaces)
    |> concat(if_clause)
    |> concat(spaces)
    |> reduce({:wrap_test, []})

  monkey =
    ignore(string("Monkey "))
    |> integer(1)
    |> concat(colon)
    |> concat(spaces)
    |> concat(starting_items)
    |> concat(operation)
    |> concat(spaces)
    |> concat(test)
    |> reduce({:wrap_monkey, []})

  monkeys = repeat(monkey)

  defparsec :monkeys, monkeys
end
