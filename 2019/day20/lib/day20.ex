defmodule Day20 do
  def part1(input) do
    grid = parse_grid(input)
    grid = find_portals(grid)
    start = find_aa(grid)
    bfs(grid, start)
  end

  def part2(input) do
    grid = parse_grid(input)
    grid = find_portals(grid)
    grid = rejigger_portals(grid)
    start = find_aa(grid)
    bfs(grid, {start, 0})
  end

  defp bfs(grid, pos) do
    bfs(grid, MapSet.new(), :gb_sets.singleton({0, pos}))
  end

  defp bfs(grid, seen, q) do
    {{path_seen, pos}, old_q} = :gb_sets.take_smallest(q)
    type = get_grid(grid, pos)
    case at_zz?(type) do
      true ->
	path_seen - 2
      false ->
	next_q = next(pos, grid, seen, path_seen, old_q)
	bfs(grid, MapSet.put(seen, pos), next_q)
    end
  end

  defp find_aa(grid) do
    Enum.find_value(grid, fn {pos, val} ->
      case val do
	{:outside, 'AA'} -> pos
	{:recursive_portal, 'AA', _, _} -> pos
	_ -> nil
      end
    end)
  end

  defp at_zz?({:outside, 'ZZ'}), do: true
  defp at_zz?({:recursive_portal, 'ZZ', _, _}), do: true
  defp at_zz?(_), do: false

  defp next(pos, grid, seen, path_seen, q) do
    neighbours = find_neighbours(pos, grid, seen)
    enqueue_neighbours(neighbours, path_seen + 1, q)
  end

  defp find_neighbours(pos, grid, seen) do
    Enum.flat_map(adjacent(pos), fn pos ->
      case get_grid(grid, pos) do
	:open -> [pos]
	{:outside, _} -> [pos]
	{:portal, _name, {_, _} = other_pos} ->
	  [other_pos]
	{:recursive_portal, _name, kind, to} ->
	  recursive_portal(pos, kind, to)
	:wall -> []
      end
    end)
    |> Enum.reject(fn pos -> MapSet.member?(seen, pos) end)
  end

  defp recursive_portal({pos, level}, kind, to) do
    case {kind,level} do
      {:aa_zz, 0} ->
	[{pos, 0}]
      {:aa_zz, _} ->
	[]
      {:up, 0} ->
	[]
      {:up, _} ->
	[{to, level - 1}]
      {:down, _} ->
	[{to, level + 1}]
    end
  end

  defp enqueue_neighbours([h | t], seen, q) do
    enqueue_neighbours(t, seen, :gb_sets.add({seen, h}, q))
  end
  defp enqueue_neighbours([], _seen, q), do: q

  defp get_grid(grid, {{_, _} = pos, _level}) do
    Map.get(grid, pos, :wall)
  end
  defp get_grid(grid, pos) do
    Map.get(grid, pos, :wall)
  end

  defp rejigger_portals(grid) do
    {{max_x, _}, _} = Enum.max_by(grid, fn {{x, _}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)
    max = {max_x, max_y}
    portals = grid
    |> Enum.flat_map(fn  {pos, what} ->
      case what do
	{:outside, name} ->
	  [{pos, {:recursive_portal, name, :aa_zz, pos}}]
	{:portal, name, to} ->
	  if outside?(pos, max) do
	    [{pos, {:recursive_portal, name, :up, to}}]
	  else
	    [{pos, {:recursive_portal, name, :down, to}}]
	  end
	_ ->
	  []
      end
    end)
    |> Map.new
    Map.merge(grid, portals)
  end

  defp outside?({x, y}, {max_x, max_y}) do
    (x < 2) or (x + 2 > max_x) or (y < 2) or (y + 2 > max_y)
  end

  defp find_portals(grid) do
    grid = Enum.filter(grid, fn
      {pos, {:portal, _}} ->
	Enum.any?(adjacent(pos), fn adj -> Map.get(grid, adj, :wall) == :open end)
      _ -> false
    end)
    |> Enum.map(fn {pos, {:portal, letter}} ->
      Enum.find_value(adjacent(pos), fn adj ->
	case grid do
	  %{^adj => {:portal, other_letter}} ->
	    case vec_sub(adj, pos) do
	      {-1, _} -> {pos, [other_letter, letter]}
	      {0, -1} -> {pos, [other_letter, letter]}
	      {_, _} -> {pos, [letter, other_letter]}
	    end
	%{} -> nil
	end
      end)
    end)
    |> Enum.group_by(fn {_, portal} -> portal end, fn {pos, _} -> pos end)
    |> Enum.reduce(grid, fn
      {portal, [pos]}, acc ->
        Map.put(acc, pos, {:outside, portal})
      {portal, [pos1, pos2]}, acc ->
	acc = Map.put(acc, pos1, {:portal, portal, hd(adjacent(pos2, grid))})
        Map.put(acc, pos2, {:portal, portal, hd(adjacent(pos1, grid))})
    end)

    bad_portal_keys = Enum.flat_map(grid, fn {key, val} ->
      case match?({:portal, _}, val) do
	true -> [key]
	false -> []
      end
    end)
    Map.drop(grid, bad_portal_keys)
  end

  defp parse_grid(input) do
    input
    |> Stream.with_index
    |> Enum.reduce([], fn {line, y}, acc ->
      String.to_charlist(line)
      |> Stream.with_index
      |> Enum.reduce(acc, fn {char, x}, acc ->
	pos = {x, y}
	case char do
	  ?\s -> acc
	  ?\# -> acc
	  ?\. -> [{pos, :open} | acc]
	  portal when portal in ?A..?Z ->
	    [{pos, {:portal, portal}} | acc]
	end
      end)
    end)
    |> Map.new
  end

  defp adjacent(pos, grid) do
    Enum.filter(adjacent(pos), fn adj ->
      case grid do
	%{^adj => :open} -> true
	%{} -> false
      end
    end)
  end

  defp adjacent({{_, _} = pos, level}) do
    Enum.map(adjacent(pos), & {&1, level})
  end
  defp adjacent({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

  defp vec_sub({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
end
