# I wrote in 2018:
#
#     It took many hours to get it working, and then I had
#     to optimize the finding of the shortest path to make
#     it finish in a reasonable time.
#
#     On my computer with my input data both parts finish
#     in less than 30 minutes. I am sure it would be possible
#     to do additional optimizations, but I had to start work
#     on the next day's puzzle.
#
# The original solution finishes both parts in 666.7 seconds
# (a little bit more than 11 minutes) on my M1 MacBook Pro.
#
# In December 2024 I rewrote the path finding algorithm to use a
# proper BFS. It now finishes in 1.9 seconds.
#

defmodule Day15 do
  def part1(lines) do
    {map, units} = read_map lines
    do_round units, map, 0
  end

  def part2(lines) do
    {map, units} = read_map lines
    do_power(units, map, 4)
  end

  defp do_power(units, map, power) when power < 40 do
    :io.format("power: ~p\n", [power])
    units = units_set_elf_power(units, power)
    try do
      res = do_round units, map, 0
      IO.inspect {:final_power, power}
      res
    catch
      :elf_killed ->
	do_power(units, map, power + 1)
    end
  end

  defp do_round(units, map, round) do
#    IO.puts("")
#    IO.inspect(round)
#    print_map(map, units)
    result = units_in_reading_order(units)
    |> Enum.reduce_while(units, fn unit_id, units ->
      unit_turn(unit_id, map, units)
    end)
    case result do
      {:ended, units} ->
	print_map(map, units)
	total_points = units_total_points(units)
        {round, total_points, round * total_points}
      units ->
	do_round(units, map, round + 1)
    end
  end

  defp unit_turn(unit_id, map, units) do
    case units do
      %{^unit_id => {pos, kind, _}} ->
        target_kind = other_unit_kind(kind)
	case adjacent_units(pos, map, units, target_kind) do
	  [_ | _] = adjacent ->
            # Already adjacent to the enemy. Attack.
	    units = do_attack(adjacent, unit_id, units);
	    {:cont, units}
	  [] ->
	    case filter_units(target_kind, units) do
	      [] ->
		{:halt, {:ended, units}}
	      [_ | _] = targets ->
		units = move(unit_id, targets, map, units)
		units = attack(unit_id, target_kind, map, units)
		{:cont, units}
	    end
	end
      %{} ->
	{:cont, units}
    end
  end

  defp attack(unit_id, target_kind, map, units) when is_integer(unit_id) do
    {pos, _, _} = Map.fetch!(units, unit_id)
    case adjacent_units(pos, map, units, target_kind) do
      [] ->
        units
      adjacent ->
        do_attack(adjacent, unit_id, units)
    end
  end

  defp do_attack(adjacent, unit_id, units) do
    adjacent
    |> Enum.map(fn position ->
      unit_id = Map.fetch!(units, position)
      {_pos, _kind, points} = Map.fetch!(units, unit_id)
      {points, position, unit_id}
    end)
    |> Enum.min
    |> then(fn {_points, _pos, target_unit_id} ->
      attack_unit(units, unit_id, target_unit_id)
    end)
  end

  defp other_unit_kind(:elf),    do: :goblin
  defp other_unit_kind(:goblin), do: :elf

  defp move(unit_id, targets, map, units) do
    {origin, kind, points} = Map.fetch!(units, unit_id)

    targets
    |> Enum.flat_map(fn {_, {pos, _, _}} ->
      empty_adjacent(pos, map, units)
    end)
    |> shortest_path(origin, map, units)
    |> then(fn new_pos ->
      case new_pos do
        nil ->
	  units
        _ ->
          units = Map.delete(units, origin)
          |> Map.put(new_pos, unit_id)
          %{units | unit_id => {new_pos, kind, points}}
      end
    end)
  end

  defp shortest_path(in_range, origin, map, units) do
    visited = MapSet.new([origin])
    paths = empty_adjacent(origin, map, units)
    |> Enum.map(&{1, &1, &1})
    |> :gb_sets.from_list

    goals = MapSet.new(in_range)

    Stream.unfold({visited, paths}, fn {visited, paths} ->
      extend_paths(paths, map, units, visited)
    end)
    |> Enum.find_value(nil, fn {current, next} ->
      if MapSet.member?(goals, current) do
        next
      else
        nil
      end
    end)
  end

  defp extend_paths(paths, map, units, visited) do
    case queue_next(paths) do
      nil ->
        nil
      {{steps, current, next}, paths} ->
        paths = empty_adjacent(current, map, units)
        |> Enum.reduce(paths, fn adj, paths ->
          cond do
            MapSet.member?(visited, adj) ->
              paths
            true ->
              :gb_sets.add({steps + 1, adj, next}, paths)
          end
        end)
        visited = MapSet.put(visited, current)
        {{current, next}, {visited, paths}}
    end
  end

  defp queue_next(paths) do
    case :gb_sets.is_empty(paths) do
      true ->
        nil
      false ->
        :gb_sets.take_smallest(paths)
    end
  end

  defp empty_adjacent(pos, map, units) do
    adjacent(pos, map, units, &(&1 === :empty))
  end

  defp adjacent_units(pos, map, units, kind) do
    adjacent(pos, map, units, &match?({:unit, _unit_id, ^kind}, &1))
  end

  defp adjacent({row, col}, map, units, include?) do
    [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
    |> Enum.filter(fn pos -> include?.(at(pos, map, units)) end)
  end

  defp at(position, {cols, map}, units) do
    {row, col} = position
    case :binary.at(map, row * cols + col) do
      ?\# ->
	:wall
      ?. ->
	case units do
	  %{^position => unit_id} ->
	    {_, kind, _} = Map.fetch!(units, unit_id)
	    {:unit, unit_id, kind}
	  %{} ->
	    :empty
	end
    end
  end

  defp filter_units(kind, units) do
    Enum.filter(units, fn unit ->
      match?({_, {_, ^kind, _}}, unit)
    end)
  end

  defp units_new(units) do
    Enum.flat_map(units, fn {unit_id, {pos, _, _}} = unit ->
      [unit, {pos, unit_id}]
    end)
    |> Map.new
  end

  defp units_set_elf_power(units, power) do
    Enum.reduce(units, units, fn unit, acc ->
      case unit do
	{unit_id, {pos, :elf, _}} ->
	  %{acc | unit_id => {pos, :elf, {200, power}}}
	_ ->
	  acc
      end
    end)
  end

  defp units_total_points(units) do
    Enum.reduce(units, 0, fn elem, acc ->
      case elem do
	{_, {_, _, {points, _}}} -> acc + points
	_ -> acc
      end
    end)
  end

  defp units_in_reading_order(units) do
    units
    |> Enum.filter(fn elem ->
      match?({id, {_, _, _}} when is_integer(id), elem)
    end)
    |> Enum.sort_by(fn {_id, {pos, _, _}} -> pos end)
    |> Enum.map(fn {id, _} -> id end)
  end

  defp attack_unit(units, attacker, target) do
    {_, _, {_, attacker_power}} = Map.fetch!(units, attacker)
    {pos, target_kind, {points, target_power}} = Map.fetch!(units, target)
    points = points - attacker_power
    if points > 0 do
      %{units | target => {pos, target_kind, {points, target_power}}}
    else
      if target_kind === :elf and target_power > 3 do
	throw(:elf_killed)
      end
      Map.delete(units, pos)
      |> Map.delete(target)
    end
  end

  defp unit_kind(units, unit_id) do
    {_, kind, _} = Map.fetch!(units, unit_id)
    kind
  end

  defp unit_points(units, unit_id) do
    {_, _, {points, _}} = Map.fetch!(units, unit_id)
    points
  end

  defp read_map(lines) do
    [cols] = Enum.dedup(Enum.map(lines, &(byte_size &1)))
    {map_string, units} = read_map_rows lines, 0, <<>>, []
    {{cols, map_string}, units_new(units)}
  end

  defp read_map_rows([line | lines], row, map_acc, unit_acc) do
    {map_acc, unit_acc} = read_map_row line, row, 0, map_acc, unit_acc
    read_map_rows lines, row + 1, map_acc, unit_acc
  end
  defp read_map_rows([], _row, map_acc, unit_acc) do
    {map_acc, unit_acc}
  end

  defp read_map_row(<<char, chars::binary>>, row, col, map_acc, unit_acc) do
    case char do
      u when u === ?E or u === ?G ->
	type = case u do
		 ?E -> :elf
		 ?G -> :goblin
	       end
	unit = {length(unit_acc), {{row, col}, type, {200, 3}}}
	map_acc = <<map_acc::binary, ?.>>
	read_map_row(chars, row, col + 1, map_acc, [unit | unit_acc])
      _ ->
	map_acc = <<map_acc::binary, char>>;
	read_map_row(chars, row, col + 1, map_acc, unit_acc)
    end
  end
  defp read_map_row(<<>>, _row, _col, map_acc, unit_acc) do
    {map_acc, unit_acc}
  end

  def print_map({cols, map}, units) do
    IO.puts print_map_1(map, 0, 0, cols, units)
  end

  defp print_map_1(chars, row, cols, cols, units) do
    points = Enum.reduce(units, [], fn elem, acc ->
      case elem do
	{unit_id, {{^row, col}, _, _}} -> [{col, unit_id} | acc]
	_ -> acc
      end
    end)
    |> Enum.sort
    |> Enum.map(fn {_, unit_id} ->
      points = unit_points(units, unit_id)
      kind = unit_kind(units, unit_id)
      :io_lib.format("~c(~p)", [unit_kind_letter(kind), points])
    end)
    |> Enum.intersperse(", ")
    ["   ", points, ?\n | print_map_1(chars, row + 1, 0, cols, units)]
  end
  defp print_map_1(<<char, chars::binary>>, row, col, cols, units) do
    pos = {row, col}
    [case units do
       %{^pos => unit_id} ->
	 unit_kind_letter(unit_kind(units, unit_id))
       _ ->
	 char
     end | print_map_1(chars, row, col + 1, cols, units)]
  end
  defp print_map_1(<<>>, _row, _col, _cols, _units) do
    []
  end

  defp unit_kind_letter(:elf), do: ?E
  defp unit_kind_letter(:goblin), do: ?G
end
