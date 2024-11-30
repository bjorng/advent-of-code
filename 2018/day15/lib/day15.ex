#
# It took many hours to get it working, and then I had
# to optimize the finding of the shortest path to make
# it finish in a reasonable time.
#
# On my computer with my input data both parts finish
# in less than 30 minutes. I am sure it would be possible
# to do additional optimizations, but I had to start work
# the next day's puzzle.
#
# The most promising idea for further optimization could
# be to cache bad paths within one turn. For example, if
# one goblin has unsuccessfully searched the whole cavern
# without finding a path to a square in range of an elf,
# other goblins could give up their search when reaching
# the first goblin.
#

defmodule Day15 do
  def part1 lines do
    {map, units} = read_map lines
    do_round units, map, 0
  end

  def part2 lines do
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
	do_power units, map, power + 1
    end
  end

  defp do_round units, map, round do
    IO.puts ""
    IO.inspect round
    print_map map, units
    result = units_in_reading_order(units)
    |> Enum.reduce_while(units, fn unit_id, acc ->
      unit_turn unit_id, map, acc
    end)
    case result do
      {:ended, units} ->
	print_map map, units
	total_points = units_total_points units
        {round, total_points, round * total_points}
      units ->
	do_round units, map, round + 1
    end
  end

  defp unit_turn unit_id, map, acc do
    case acc[unit_id] do
      {pos, kind, _} ->
	target_kind = other_unit_kind(kind)
	case adjacent_units(pos, map, acc, target_kind) do
	  [] ->
	    targets = unit_targets(kind, acc)
	    case targets do
	      [] ->
		{:halt, {:ended, acc}}
	      [_ | _] ->
		acc = move(unit_id, targets, map, acc)
		acc = attack(unit_id, target_kind, map, acc)
		{:cont, acc}
	    end
	  [_ | _] ->
            # Already adjacent to the enemy. Attack.
	    acc = attack(unit_id, target_kind, map, acc);
	    {:cont, acc}
	end
      nil ->
	{:cont, acc}
    end
  end

  defp move unit_id, targets, map, units do
    {pos, _kind, _points} = units[unit_id]
    new_pos = targets
    |> Enum.flat_map(fn {_, {pos, _, _}} ->
      empty_adjacent(pos, map, units)
    end)
    |> Enum.sort
    |> MapSet.new
    |> shortest_paths(pos, map, units)
    |> find_move

    case new_pos do
      nil ->
	units
      _ ->
	move_unit units, unit_id, new_pos
    end
  end

  defp find_move paths do
    sorted = paths
    |> Enum.map(fn [final | _] = path -> {final, second_last(path)} end)
    |> Enum.sort

    case sorted do
      [{_, step} | _] -> step
      [] -> nil
    end
  end

  defp second_last([sl, _]), do: sl
  defp second_last([_ | t]), do: second_last(t)

  defp attack(unit_id, target_kind, map, units) when is_integer(unit_id) do
    {pos, _, _} = units[unit_id]
    case adjacent_units(pos, map, units, target_kind) do
      [] ->
	units
      [_ | _] = enemies ->
	targeted = enemies
	|> Enum.map(fn position ->
	  {:unit, unit_id, kind} = at(position, map, units);
	  {_pos, ^kind, points} = units[unit_id]
	  {points, position, unit_id}
	end)
	|> Enum.sort
	|> hd
	{_points, _pos, target_unit_id} = targeted
	attack_unit units, unit_id, target_unit_id
    end
  end

  defp other_unit_kind(:elf),    do: :goblin
  defp other_unit_kind(:goblin), do: :elf

  defp shortest_paths in_range, root, map, units do
    if MapSet.size(in_range) == 0 do
      []
    else
      visited = MapSet.new([root])
      shortest_paths in_range, [[root]], map, units, visited
    end
  end

  defp shortest_paths in_range, paths, map, units, visited do
    case extend_paths paths, map, units, visited, [] do
      [] ->
	[]
      [_|_] = paths ->
	case Enum.filter(paths, fn [pos | _] -> pos in in_range end) do
	  [_ | _] = paths ->
	    paths
	  [] ->
	    newly_visited = Enum.map(paths, fn [pos | _] -> pos end)
	    visited = MapSet.union visited, MapSet.new(newly_visited)
	    shortest_paths in_range, paths, map, units, visited
	end
    end
  end

  defp extend_paths [[pos | _] = path | paths], map, units, visited, acc do
    new_squares = adjacent_squares(pos)
    |> Enum.reject(fn pos ->
      pos in visited || is_occupied(pos, map, units)
    end)
    acc = add_new_paths(new_squares, path, acc)
    extend_paths(paths, map, units, visited, acc)
  end

  defp extend_paths [], _map, _units, _visited, acc do
    acc
  end

  defp add_new_paths([square | squares], path, acc) do
    add_new_paths squares, path, [[square | path] | acc]
  end

  defp add_new_paths([], _path, acc) do
    acc
  end

  defp empty_adjacent pos, map, units do
    adjacent pos, map, units, &(&1 == :empty)
  end

  defp adjacent_units pos, map, units, kind do
    adjacent(pos, map, units, fn content ->
      case content do
	{:unit, _unit_id, ^kind} ->
	  true
	_ ->
	  false
      end
    end)
  end

  defp is_occupied pos, map, units do
    case raw_at(pos, map) do
      :wall ->
	true
      :empty_or_unit ->
	units[pos] != nil
    end
  end

  defp adjacent {row, col}, map, units, fun do
    [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
    |> Enum.filter(fn pos -> fun.(at(pos, map, units)) end)
  end

  defp adjacent_squares {row, col} do
    [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
  end

  defp at pos, map, units do
    case raw_at(pos, map) do
      :empty_or_unit ->
	case units[pos] do
	  nil ->
	    :empty
	  unit_id ->
	    {_, kind, _} = units[unit_id];
	    {:unit, unit_id, kind}
	end
      wall ->
	wall
    end
  end

  defp raw_at {row, col} = pos, {cols, map} do
    case :binary.at(map, row * cols + col) do
      ?\# ->
	:wall
      ?. ->
	:empty_or_unit
    end
  end

  defp unit_targets kind, units do
    target_kind = other_unit_kind kind
    Enum.filter(units, fn other_unit ->
      match?({_, {_, ^target_kind, _}}, other_unit)
    end)
  end

  defp units_new units do
    Enum.flat_map(units, fn {unit_id, {pos, _, _}} = unit ->
      [unit, {pos, unit_id}]
    end)
    |> Map.new
  end

  defp units_set_elf_power units, power do
    Enum.reduce(units, units, fn unit, acc ->
      case unit do
	{unit_id, {pos, :elf, _}} ->
	  %{acc | unit_id => {pos, :elf, {200, power}}}
	_ ->
	  acc
      end
    end)
  end

  defp units_total_points units do
    Enum.reduce(units, 0, fn elem, acc ->
      case elem do
	{_, {_, _, {points, _}}} -> acc + points
	_ -> acc
      end
    end)
  end

  defp units_in_reading_order units do
    units
    |> Enum.filter(fn elem ->
      match?({id, {_, _, _}} when is_integer(id), elem)
    end)
    |> Enum.sort_by(fn {_id, {pos, _, _}} -> pos end)
    |> Enum.map(fn {id, _} -> id end)
  end

  defp attack_unit units, attacker, target do
    {_, _, {_, attacker_power}} = units[attacker]
    {pos, target_kind, {points, target_power}} = units[target]
    case (points - attacker_power) do
      points when points > 0 ->
	%{units | target => {pos, target_kind, {points, target_power}}}
      _ ->
	if target_kind == :elf and target_power > 3 do
	  throw(:elf_killed)
	end
	kill_unit units, target
    end
  end

  defp move_unit units, unit_id, new_pos do
    {old_pos, kind, points} = units[unit_id]
    units = Map.delete(units, old_pos)
    units = Map.put(units, new_pos, unit_id)
    %{units | unit_id => {new_pos, kind, points}}
  end

  defp kill_unit units, unit_id do
    {pos, _, _} = units[unit_id]
    units = Map.delete(units, pos)
    Map.delete(units, unit_id)
  end

  defp unit_kind units, unit_id do
    {_, kind, _} = units[unit_id]
    kind
  end

  defp unit_points units, unit_id do
    {_, _, {points, _}} = units[unit_id]
    points
  end

  defp read_map lines do
    [cols] = Enum.dedup(Enum.map(lines, &(byte_size &1)))
    {map_string, units} = read_map_rows lines, 0, <<>>, []
    {{cols, map_string}, units_new(units)}
  end

  defp read_map_rows [line | lines], row, map_acc, unit_acc do
    {map_acc, unit_acc} = read_map_row line, row, 0, map_acc, unit_acc
    read_map_rows lines, row + 1, map_acc, unit_acc
  end

  defp read_map_rows [], _row, map_acc, unit_acc do
    {map_acc, unit_acc}
  end

  defp read_map_row <<char, chars::binary>>, row, col, map_acc, unit_acc do
    case char do
      u when u == ?E or u == ?G ->
	type = case u do
		 ?E -> :elf
		 ?G -> :goblin
	       end
	unit = {length(unit_acc), {{row, col}, type, {200, 3}}}
	map_acc = <<map_acc::binary, ?.>>
	read_map_row chars, row, col + 1, map_acc, [unit | unit_acc]
      _ ->
	map_acc = <<map_acc::binary, char>>;
	read_map_row chars, row, col + 1, map_acc, unit_acc
    end
  end

  defp read_map_row <<>>, _row, _col, map_acc, unit_acc do
    {map_acc, unit_acc}
  end

  def print_map {cols, map}, units do
    IO.puts print_map_1(map, 0, 0, cols, units)
  end

  defp print_map_1 chars, row, cols, cols, units do
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

  defp print_map_1 <<char, chars::binary>>, row, col, cols, units do
    pos = {row, col}
    [case units do
       %{^pos => unit_id} ->
	 unit_kind_letter(unit_kind(units, unit_id))
       _ ->
	 char
     end | print_map_1(chars, row, col + 1, cols, units)]
  end

  defp print_map_1 <<>>, _row, _col, _cols, _units do
    []
  end

  defp unit_kind_letter(:elf), do: ?E
  defp unit_kind_letter(:goblin), do: ?G

end
