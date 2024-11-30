defmodule Day19 do
  def part1(input) do
    {workflows, parts} = parse(input)

    parts
    |> Enum.filter(&execute(workflows, &1))
    |> Enum.map(fn part ->
      Enum.sum(Map.values(part))
    end)
    |> Enum.sum
  end

  defp execute(workflows, part) do
    execute(workflows, part, :in)
  end

  defp execute(workflows, part, current) do
    Map.fetch!(workflows, current)
    |> execute_rules(workflows, part)
  end

  defp execute_rules([{condition, action} | rules], workflows, part) do
    case condition do
      {op,var,arg} ->
        apply(:erlang, op, [Map.fetch!(part, var), arg])
      true ->
        true
    end
    |> then(fn bool ->
      if bool do
        case action do
          :A -> true
          :R -> false
          _ -> execute(workflows, part, action)
        end
      else
        execute_rules(rules, workflows, part)
      end
    end)
  end

  def part2(input) do
    {workflows, _parts} = parse(input)
    part2_execute(workflows)
    |> Enum.map(fn part ->
      Enum.map(part, fn {_key, list} ->
        length(list)
      end)
      |> Enum.product
    end)
    |> Enum.sum
  end

  defp part2_execute(workflows) do
    all = Enum.to_list(1..4000)
    part = %{x: all, m: all, a: all, s: all}
    part2_execute(workflows, part, :in)
  end

  defp part2_execute(workflows, part, current) do
    Map.fetch!(workflows, current)
    |> part2_execute_rules(workflows, part)
  end

  defp part2_execute_rules([{condition, action} | rules], workflows, part) do
    case condition do
      {op,var,arg} ->
        values = Map.fetch!(part, var)
        {vs1, vs2} = Enum.split_with(values, &apply(:erlang, op, [&1, arg]))
        part_true = Map.put(part, var, vs1)
        part_false = Map.put(part, var, vs2)
        part2_execute_rules(rules, workflows, part_false) ++
          part2_execute_action(action, workflows, part_true)
      true ->
        part2_execute_action(action, workflows, part)
    end
  end

  defp part2_execute_action(action, workflows, part) do
    case action do
      :A -> [part]
      :R -> []
      _ -> part2_execute(workflows, part, action)
    end
  end

  defp parse(input) do
    [workflows, parts] = input

    workflows = workflows
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [name, rules] = String.split(line, ["{", "}"], trim: true)
      name = String.to_atom(name)
      rules = String.split(rules, ",")
      |> Enum.map(fn rule ->
        case String.split(rule, ":") do
          [condition, workflow] ->
            <<var, op, integer :: binary>> = condition
            condition = {List.to_atom([op]), List.to_atom([var]),
                         String.to_integer(integer)}
            {condition, String.to_atom(workflow)}
          [workflow] ->
            {true, String.to_atom(workflow)}
        end
      end)
      {name, rules}
    end)
    |> Map.new

    parts = parts
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ["{", ",", "}"], trim: true)
      |> Enum.map(fn part ->
        [var, integer] = String.split(part, "=")
        {String.to_atom(var), String.to_integer(integer)}
      end)
      |> Map.new
    end)

    {workflows, parts}
  end
end
