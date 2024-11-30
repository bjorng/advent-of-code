#
# Translated to Elixir from Fred Hebert's Erlang solution:
#    https://elixirforum.com/t/advent-of-code-2019-day-18/27657/4
#
# I replaced the use of `queue` with `gb_sets`, which seems to be
# make it slightly faster. I also eliminated the use of list_to_atom/1
# and atom_to_list/1, and made some other minor changes.
#

defmodule Day18 do
  def part1(input) do
    solve(input)
  end

  def part2(input) do
    input = correct_map(input)
    solve(input)
  end

  defp correct_map([a, b, c | tail]) do
    case String.split(b, ".@.") do
      [first, last] ->
        b = first <> "###" <> last
        size = byte_size(first)
        <<first :: binary-size(size),
          _ :: binary-size(3),
          last :: binary>> = a
        a = first <> "@#@" <> last
        <<first :: binary-size(size),
          _ :: binary-size(3),
          last :: binary>> = c
        c = first <> "@#@" <> last
        [a, b, c | tail]
      [_] ->
        [a | correct_map([b, c | tail])]
    end
  end
  defp correct_map([a, b]) do
    [a, b]
  end

  defp solve(input) do
    {map, keys, doors, ps} = process_input(input)
    parent = self()
    spawn_link(fn -> send(parent, cached_search(ps, map, keys, doors)) end)
    receive do
      result -> result
    end
  end

  def cached_search(ps, map, keys, doors) do
    key = {ps, keys, doors}
    case Process.get(key) do
      nil ->
        result = search(ps, map, keys, doors)
	Process.put(key, result)
	result
      result ->
        result
    end
  end

  defp search(ps, map, keys, doors) do
    new_pos_keys = search_keys(ps, map, keys, doors)
    for {old_pos, new_keys} <- new_pos_keys, {k, path_length} <- new_keys do
      cached_search(swap_pos(old_pos, Map.get(keys, k), ps),
        map,
        Map.delete(keys, k),
        unlock(k, doors)) + path_length
    end
    |> Enum.min(fn -> 0 end)
  end

  defp swap_pos(p, k, [p | t]), do: [k | t]
  defp swap_pos(p, k, [h | t]), do: [h | swap_pos(p, k, t)]

  defp unlock({:key, n}, doors) do
    door = {:door, n}
    Map.put(doors, door, :unlocked)
  end

  defp search_keys(pos, map, keys, doors) do
    for p <- pos, do: {p, search_key(p, map, keys, doors)}
  end

  defp search_key(pos, map, keys, doors) do
    search_key(map, keys, doors, MapSet.new(), :gb_sets.singleton({0, pos}), [])
  end

  defp search_key(map, keys, doors, seen, q, new_keys) do
    case :gb_sets.is_empty(q) do
      true ->
        new_keys
      false ->
        case :gb_sets.take_smallest(q) do
	  {{path_seen, pos}, old_q} ->
            case map do
	      %{^pos => :open} ->
                next_q = next(pos, map, seen, path_seen, old_q)
	          search_key(map, keys, doors, MapSet.put(seen, pos), next_q, new_keys)
	      %{^pos => {:key,_} = key} ->
		case keys do
		  %{^key => _} ->
                    search_key(map, keys,
                      doors, Map.put(seen, pos, true), old_q,
                      [{key, path_seen} | new_keys])
		  %{} ->
                    next_q = next(pos, map, seen, path_seen, old_q)
                    search_key(map, keys, doors, MapSet.put(seen, pos), next_q, new_keys)
                end
	      %{^pos => {:door,_} = door} ->
                case doors do
		  %{^door => :unlocked} ->
                    next_q = next(pos, map, seen, path_seen, old_q)
                    search_key(map, keys, doors, MapSet.put(seen, pos), next_q, new_keys)
		  %{^door => _} ->
                    search_key(map, keys, doors, MapSet.put(seen, pos), old_q, new_keys)
                end
	      %{} ->
                search_key(map, keys, doors, seen, old_q, new_keys)
            end
        end
    end
  end

  defp next(pos, map, seen, path_seen, q) do
    neighbours = find_neighbours(pos, map, seen)
    enqueue_neighbours(neighbours, path_seen + 1, q)
  end

  defp find_neighbours({x, y}, map, seen) do
    for pos <- [{x+1,y}, {x-1,y}, {x,y+1}, {x,y-1}],
      :erlang.is_map_key(pos, map) and not MapSet.member?(seen, pos) do
      pos
    end
  end

  defp enqueue_neighbours([h | t], seen, q) do
    enqueue_neighbours(t, seen, :gb_sets.add({seen, h}, q))
  end
  defp enqueue_neighbours([], _seen, q), do: q

  defp process_input(input) do
    process_input(parse_grid(input), %{}, %{}, %{}, [])
  end

  defp process_input([{pos, type} | tail], map, keys, doors, ps) do
    map = Map.put(map, pos, type)
    case type do
      :open ->
	process_input(tail, map, keys, doors, ps)
      :entrance ->
	process_input(tail, Map.put(map, pos, :open), keys, doors, [pos | ps])
      {:door, _} ->
	process_input(tail, map, keys, Map.put(doors, type, pos), ps)
      {:key, _} ->
	process_input(tail, map, Map.put(keys, type, pos), doors, ps)
    end
  end
  defp process_input([], map, keys, doors, ps), do: {map, keys, doors, ps}

  defp parse_grid(input) do
    input
    |> Stream.with_index
    |> Enum.reduce([], fn {line, y}, acc ->
      String.to_charlist(line)
      |> Stream.with_index
      |> Enum.reduce(acc, fn {char, x}, acc ->
	pos = {x, y}
	case char do
	  ?\# -> acc
	  ?\. -> [{pos, :open} | acc]
	  ?\@ -> [{pos, :entrance} | acc]
	  door when door in ?A..?Z ->
 	    [{pos, {:door, door - ?A}} | acc]
	  key when key in ?a..?z ->
 	    [{pos, {:key, key - ?a}} | acc]
	end
      end)
    end)
  end
end
