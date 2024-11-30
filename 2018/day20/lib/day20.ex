defmodule Day20 do
  def part1(regex) do
    parse_regex(regex)
    |> build_graph
    |> all_paths
    |> Stream.with_index(-1)
    |> Enum.find_value(fn {set, num_doors} ->
      if MapSet.size(set) == 0 do
        num_doors
      else
        nil
      end
    end)
  end

  def part2(regex, doors_to_pass) do
    parse_regex(regex)
    |> build_graph
    |> all_paths
    |> Stream.drop(doors_to_pass)
    |> Enum.reduce_while(MapSet.new(), fn rooms, acc ->
      if MapSet.size(rooms) == 0 do
        {:halt, MapSet.size(acc)}
      else
        {:cont, MapSet.union(rooms, acc)}
      end
    end)
  end

  defp all_paths(graph) do
    origin = MapSet.new([{0, 0}])
    {origin, origin}
    |> Stream.iterate(fn {visited, rooms} -> expand_paths(visited, rooms, graph) end)
    |> Stream.map(fn {_visited, rooms} -> rooms end)
  end

  defp expand_paths visited, rooms, graph do
    Enum.reduce(rooms, {visited, MapSet.new()},
      fn path, {visited, rooms} ->
	case next_path_positions(graph, visited, path) do
	  [] ->
	    {visited, rooms}
	  next_path_positions ->
            next_path_positions = MapSet.new(next_path_positions)
	    visited = MapSet.union(visited, next_path_positions);
	    {visited, MapSet.union(rooms, next_path_positions)}
	end
      end)
  end

  defp next_path_positions graph, visited, position do
    adjacent_positions(position)
    |> Enum.reject(&MapSet.member?(visited, &1))
    |> Enum.filter(fn adjacent -> MapSet.member?(graph, {position, adjacent}) end)
  end

  defp adjacent_positions({x, y}), do: [{x, y + 1}, {x, y - 1}, {x - 1, y}, {x + 1, y}]

  # From the parsed regexp, build a graph of the connections between the
  # rooms. This function actually solves a slightly more general problem
  # than actually needed: it is not assumed that a group of alternative
  # paths always return to the main path.
  #
  # See this discussion in the subreddit:
  #
  # https://www.reddit.com/r/adventofcode/comments/a7w4dj/2018_day_20_why_does_this_work/

  defp build_graph directions do
    {_pos, graph} = build_graph directions, {0, 0}, MapSet.new()
    graph
  end

  defp build_graph([alt_dirs | directions], pos, acc) when is_list(alt_dirs) do
    build_alt_dirs alt_dirs, directions, pos, acc
  end

  defp build_graph [direction | directions], {x, y} = from, acc do
    to = case direction do
	   :north -> {x,     y + 1}
	   :south -> {x,     y - 1}
	   :west ->  {x - 1, y}
	   :east ->  {x + 1, y}
	 end
    connection = {from, to}
    case MapSet.member?(acc, connection) do
      true ->
	build_graph(directions, to, acc)
      false ->
	acc = MapSet.put(acc, connection)
	acc = MapSet.put(acc, {to, from})
	build_graph(directions, to, acc)
    end
  end

  defp build_graph([], pos, acc), do: {[pos], acc}

  defp build_alt_dirs(alt_dirs, directions, pos, acc) do
    {positions, acc} = Enum.map_reduce(alt_dirs, acc, fn alt_dir, acc ->
      build_graph alt_dir, pos, acc
    end)

    {positions, acc} = positions
    |> Enum.concat
    |> Enum.uniq
    |> Enum.map_reduce(acc, fn pos, acc ->
      build_graph directions, pos, acc
    end)

    positions = positions
    |> Enum.concat
    |> Enum.uniq

    {positions, acc}
  end

  defp parse_regex <<"^", rest::binary>> do
    {?\$, <<>>, result} = parse_direction rest, []
    result
  end

  defp parse_direction <<char, rest::binary>>, acc do
    case char do
      ?N -> parse_direction rest, [:north | acc]
      ?W -> parse_direction rest, [:west | acc]
      ?E -> parse_direction rest, [:east | acc]
      ?S -> parse_direction rest, [:south | acc]
      ?\( ->
	{alt, rest} = parse_alt rest, []
	parse_direction rest, [alt | acc]
      other ->
	{other, rest, Enum.reverse(acc)}
    end
  end

  defp parse_alt rest, acc do
    {terminator, rest, alt_group} = parse_direction rest, []
    case terminator do
      ?| -> parse_alt rest, [alt_group | acc]
      ?\) -> {Enum.reverse(acc, [alt_group]), rest}
    end
  end
end
