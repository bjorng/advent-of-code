defmodule Day24 do
  def part1(lines, boost \\ 0) do
    groups = parse(lines)
    groups = boost(groups, boost)
    cycle(groups)
  end

  def part2(lines) do
    groups = parse(lines)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(nil, fn boost, _acc ->
      boosted_groups = boost(groups, boost)
      case cycle(boosted_groups) do
        {:immune_system, units} ->
          {:halt, {units, boost}}
        {:infection, _units} ->
          #:io.format("boost: ~p; 0/~p\n", [boost, _units])
          {:cont, nil}
        {:stalemate, {_imm_units, _inf_units}} ->
          #:io.format("boost: ~p; stalemate: ~p/~p\n", [boost, _imm_units, _inf_units])
          {:cont, nil}
      end
    end)
  end

  defp boost(groups, boost) do
    groups
    |> Enum.map(fn {id, group} ->
      case group do
        %{side: :immune_system, damage: damage} ->
          {id, %{group | damage: damage + boost}}
        %{} ->
          {id, group}
      end
    end)
    |> Enum.into(%{})
  end

  defp cycle(groups) do
    #print_groups groups

    old_groups = groups

    selection_order = groups
    |> Enum.sort_by(&selection_order/1)
    |> Enum.reverse

    acc = {groups, []}
    {_, attack_order} = Enum.reduce(selection_order, acc, &select_target/2)

    attack_order =
      Enum.sort_by(attack_order, fn {attacker_id, _attacked_id} ->
        attacker = Map.fetch!(groups, attacker_id)
        - attacker.initiative
      end)

    groups = Enum.reduce(attack_order, groups, &attack/2)

    case count_units(groups) do
      {0, units} ->
        #print_groups groups
        {:infection, units}
      {units, 0} ->
        #print_groups groups
        {:immune_system, units}
      {imm_units, inf_units} ->
        if groups === old_groups do
          {:stalemate, {imm_units, inf_units}}
        else
          cycle(groups)
        end
    end
  end

  defp count_units(groups) do
    Enum.reduce(groups, {0, 0}, fn {_, group}, {imm, inf} ->
      case group do
        %{side: :immune_system, units: units} ->
          {imm + units, inf}
        %{side: :infection, units: units} ->
          {imm, inf + units}
      end
    end)
  end

  defp attack({attacker_id, attacked_id}, groups)
  when :erlang.is_map_key(attacker_id, groups) do
    %{^attacker_id => attacker, ^attacked_id => attacked} = groups
    damage = damage(attacker, attacked)
    %{units: units, hit_points: hit_points} = attacked
    units_hit = div(damage, hit_points)
    case (units - units_hit) do
      units when units > 0 ->
        attacked = %{attacked | units: units}
        %{groups | attacked_id => attacked}
      _ ->
        Map.delete(groups, attacked_id)
    end
  end

  defp attack({_, _}, groups), do: groups

  defp select_target({id, group}, {avail, chosen}) do
    my_side = group.side
    attacked = Enum.reject(avail, fn {_, %{side: side}} ->
      side == my_side
    end)
    |> Enum.map(fn {_, attacked} ->
      target_selection_order(group, attacked)
    end)
    |> Enum.max_by(fn {order, _} -> order end,
    fn -> {{0, nil, nil}, nil} end)
    |> (fn
      {{0, _, _}, _} -> nil
      {{_, _, _}, attacked} -> attacked
    end).()

    case attacked do
      nil ->
        {avail, chosen}
      _ ->
        avail = Map.delete(avail, attacked)
        {avail, [{id, attacked} | chosen]}
    end
  end

  defp target_selection_order(attacker, attacked) do
    damage = damage(attacker, attacked)
    order = {damage, effective_power(attacked), attacked.initiative}
    {order, attacked.id}
  end

  defp selection_order({id, group}) do
    {{effective_power(group), group.initiative}, id}
  end

  defp damage(attacker, attacked) do
    power = effective_power(attacker)
    weapon = attacker.weapon
    %{immunities: immunities, weaknesses: weaknesses} = attacked
    cond do
      weapon in immunities -> 0
      weapon in weaknesses -> 2 * power
      true -> power
    end
  end

  defp effective_power(%{damage: damage, units: units}) do
    damage * units
  end

  defp parse(lines) do
    parse(lines, nil)
    |> Enum.map_reduce({1, 1}, fn group, {imm, inf} ->
      case group.side do
        :immune_system ->
          id = {:immune_system, imm}
          group = Map.put(group, :id, id)
          {{id, group}, {imm + 1, inf}}
        :infection ->
          id = {:infection, inf}
          group = Map.put(group, :id, id)
          {{id, group}, {imm, inf + 1}}
      end
    end)
    |> (fn {groups, {_, _}} -> groups end).()
    |> Map.new
  end

  defp parse(["Immune System:" | lines], _side) do
    parse(lines, :immune_system)
  end

  defp parse(["Infection:" | lines], _side) do
    parse(lines, :infection)
  end

  defp parse([line | lines], side) do
    group = parse_group(line)
    group = Map.put(group, :side, side)
    [group | parse(lines, side)]
  end

  defp parse([], _side), do: []

  defp parse_group(line) do
    {units, line} = Integer.parse(line)
    <<" units each with ", line::binary>> = line
    {hit_points, line} = Integer.parse(line)
    <<" hit points ", line::binary>> = line
    {imm_weak, line} = parse_imm_weak(line)
    <<"with an attack that does ", line::binary>> = line
    {damage, line} = Integer.parse(line)
    <<" ", line::binary>> = line
    {weapon, line} = parse_damage(line)
    <<" damage at initiative ", line::binary>> = line
    {initiative, ""} = Integer.parse(line)
    group = Map.new([units: units, hit_points: hit_points,
                     damage: damage, weapon: weapon,
                     initiative: initiative,
                     immunities: [], weaknesses: []])
    Map.merge(group, imm_weak)
  end

  defp parse_imm_weak(<<"(", line::binary>>) do
    parse_imm_weak(line, %{})
  end

  defp parse_imm_weak(line), do: {%{}, line}

  defp parse_imm_weak(<<"immune to ", line::binary>>, acc) do
    {list, line} = parse_list(line, [])
    acc = Map.put(acc, :immunities, list)
    parse_imm_weak(line, acc)
  end

  defp parse_imm_weak(<<"weak to ", line::binary>>, acc) do
    {list, line} = parse_list(line, [])
    acc = Map.put(acc, :weaknesses, list)
    parse_imm_weak(line, acc)
  end

  defp parse_imm_weak(<<"; ", line::binary>>, acc) do
    parse_imm_weak(line, acc)
  end

  defp parse_imm_weak(<<") ", line::binary>>, acc) do
    {acc, line}
  end

  defp parse_list(line, acc) do
    {item, line} = parse_damage(line)
    acc = [item | acc]
    case line do
      <<", ", line::binary>> ->
        parse_list(line, acc)
      _ ->
        {Enum.sort(acc), line}
    end
  end

  defp parse_damage(line) do
    case line do
      <<"bludgeoning", line::binary>> ->
        {:bludgeoning, line}
      <<"cold", line::binary>> ->
        {:cold, line}
      <<"fire", line::binary>> ->
        {:fire, line}
      <<"radiation", line::binary>> ->
        {:radiation, line}
      <<"slashing", line::binary>> ->
        {:slashing, line}
    end
  end

  def print_groups(groups) do
    IO.puts groups
    |> Enum.sort
    |> Enum.map(&print_group/1)
  end

  defp print_group({{side, id}, group}) do
    :io_lib.format("~p group ~p contains ~p units\n",
      [side, id, group.units])
  end

end
