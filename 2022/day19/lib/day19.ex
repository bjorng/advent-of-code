defmodule Day19 do
  def part1(input) do
    parse(input)
    |> Enum.map(fn blueprint -> solve_blueprint(blueprint, 24) end)
    |> Enum.map(fn {id, n} -> id * n end)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.take(3)
    |> Enum.map(fn blueprint -> solve_blueprint(blueprint, 32) end)
    |> Enum.map(fn {_id, n} -> n end)
    |> Enum.product
  end

  defp solve_blueprint({id, blueprint}, minutes) do
    have = %{ore: 0, clay: 0, obsidian: 0, geode: 0}
    delta = %{have | ore: 1}
    states = [{have, delta}]
    Stream.unfold({minutes + 1, states}, fn {left, states} ->
      next_minute(states, left, blueprint)
    end)
    |> Stream.drop(minutes - 1)
    |> Enum.take(1)
    |> hd
    |> result(id)
  end

  defp result(states, id) do
    {%{geode: n}, _} = Enum.max_by(states, fn {%{geode: n}, _} -> n end)
#    IO.inspect {id, n, Enum.count(states)}
    {id, n}
  end

  defp next_minute(states, minutes_left, blueprint) do
    {%{geode: best}, _} =
      Enum.max_by(states, fn {%{geode: n}, _} -> n end)
    [_, _, obsidian: [ore: _, clay: _clay_needed],
     geode: [ore: _, obsidian: obsidian_needed]] = blueprint
    max_obsidian = minutes_left * (minutes_left + 1)
    states = Enum.filter(states, fn {%{geode: geodes, clay: _clay, obsidian: obsidian},
                                      %{clay: _clay_produced, obsidian: obsidian_produced}} ->
      max_geodes = div(obsidian + obsidian_produced * minutes_left + max_obsidian, obsidian_needed) + 1
      geodes + max_geodes >= best
    end)
    |> Enum.flat_map(fn state ->
      new_states(state, blueprint, minutes_left)
    end)
    |> MapSet.new
    {states, {minutes_left - 1, states}}
  end

  defp new_states({have, delta}, blueprint, minutes_left) do
    current(have, delta, blueprint) ++ build_robots(have, delta, blueprint, minutes_left)
    |> Enum.map(fn {have, delta} ->
      %{ore: ore, clay: clay, obsidian: obsidian} = have
      %{ore: delta_ore, clay: delta_clay, obsidian: delta_obsidian} = delta
      have = %{have | ore: min(ore + delta_ore, 50),
               clay: min(clay + delta_clay, 50),
               obsidian: obsidian + delta_obsidian}
      {have, delta}
    end)
  end

  defp current(have, delta, blueprint) do
    discard = Enum.all?(blueprint, fn {_resource, needed} ->
      Enum.all?(needed, fn {resource, n} ->
        Map.fetch!(delta, resource) === 0 or Map.fetch!(have, resource) >= n
      end)
    end)
    case discard do
      true -> []
      false -> [{have, delta}]
    end
  end

  defp build_robots(have, delta, blueprint, minutes_left) do
    Enum.flat_map(blueprint, fn {resource, needed} ->
      case Enum.all?(needed, fn {need, n} ->
            Map.fetch!(have, need) >= n
          end) do
        true ->
          case need_robot?(resource, have, delta, blueprint, minutes_left) do
            true ->
              case resource do
                :geode ->
                  have =
                    Enum.reduce(needed, have, fn {need, n}, have ->
                      Map.update!(have, need, &(&1 - n))
                    end)
                    |> Map.update!(resource, &(&1 + minutes_left - 2))
                  [{have, delta}]
                _ ->
                  delta = Map.update!(delta, resource, &(&1 + 1))
                  have = Enum.reduce(needed, have, fn {need, n}, have ->
                    Map.update!(have, need, &(&1 - n))
                  end)
                  |> Map.update!(resource, &(&1 - 1))
                  [{have, delta}]
              end
            false ->
              []
          end
        false ->
          []
      end
    end)
  end

  defp need_robot?(:geode, _have, _delta, _blueprint, _minutes_left), do: true
  defp need_robot?(resource, have, delta, blueprint, minutes_left) do
    cond do
      resource === :clay and minutes_left < 5 ->
        false
      resource in [:ore, :obsidian] and minutes_left < 3 ->
        false
      resource === :geode and minutes_left < 1 ->
        false
      resource in [:ore, :clay, :obsidian] ->
        current_resource = Map.fetch!(have, resource)
        resource_per_minute = Map.fetch!(delta, resource)
        highest = highest_cost(resource, blueprint)
        max = max(highest, highest * (minutes_left - 1) - resource_per_minute * (minutes_left - 2))
        resource_per_minute < highest and current_resource < max
      true ->
        true
    end
  end

  defp highest_cost(resource, blueprint) do
    Enum.flat_map(blueprint, fn {_, costs} ->
      Enum.flat_map(costs, fn
        {^resource, cost} ->
          [cost]
        _ ->
          []
      end)
    end)
    |> Enum.max(&>=/2, fn -> 0 end)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      "Blueprint " <> rest = line
      {blueprint, ": " <> rest} = Integer.parse(rest)
      words = String.split(rest)
      {ore_robot_ore, words} = parse_robot(words, "ore")
      {clay_robot_ore, words} = parse_robot(words, "clay")
      {obsidian_robot_ore, obsidian_robot_clay, words} = parse_robot(words, "obsidian")
      {geode_robot_ore, geode_robot_obsidian, []} = parse_robot(words, "geode")
      {blueprint, [{:ore, [ore: ore_robot_ore]},
                   {:clay, [ore: clay_robot_ore]},
                   {:obsidian, [ore: obsidian_robot_ore, clay: obsidian_robot_clay]},
                   {:geode, [ore: geode_robot_ore, obsidian: geode_robot_obsidian]}]}
    end)
  end

  defp parse_robot(["Each", kind, "robot", "costs", ore | words], kind) do
    ore = String.to_integer(ore)
    case words do
      ["ore." | words] ->
        {ore, words}
      ["ore", "and", other, _ | words] ->
        other = String.to_integer(other)
        {ore, other, words}
    end
  end
end
