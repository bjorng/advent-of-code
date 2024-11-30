#
# A brute-force solution that find the three edges in about 78 minutes
# on my computer.
#
# The idea is to try all combinations of removing two edges. With two
# edges removed, the last edge to cut (the bridge edge) can be found
# using a simple algorithm based on DFS.
#

defmodule Day25 do
  def part1(input) do
    g = parse(input)
    solve(g)
  end

  defp solve(g) do
    edges = :digraph.edges(g)
    do_solve(g, edges, 0)
  end

  defp do_solve(g, [{v, _} | _], 2) do
    case find_bridge(g, v) do
      nil ->
        nil
      {:bridge, v1, v2} ->
        :digraph.del_edge(g, {v1, v2})
        :digraph.del_edge(g, {v2, v1})
        IO.inspect {v1, v2}
        [c1, c2] = :digraph_utils.components(g)
        length(c1) * length(c2)
    end
  end
  defp do_solve(_g, [], _n), do: nil
  defp do_solve(g, [e | edges], n) do
    if n === 0 do
      :io.format("\r~p     ", [length(edges)])
    end
    :digraph.del_edge(g, e)
    case do_solve(g, edges, n + 1) do
      nil ->
        add_back_edges(g, e)
        do_solve(g, edges, n)
      result when is_integer(result) ->
        result
    end
  end

  defp add_back_edges(g, {v1, v2}) do
    :digraph.add_edge(g, {v1, v2}, v1, v2, [])
  end

  defp find_bridge(g, v) do
    pre = low = Map.new()
    case find_bridge(g, nil, v, pre, low) do
      {_, _} ->
        nil
      {:bridge, _, _} = bridge ->
        bridge
    end
  end

  defp find_bridge(g, parent, v, pre, low) do
    order = map_size(pre)
    pre = Map.put(pre, v, order)
    low = Map.put(low, v, order)
    vs = :digraph.in_neighbours(g, v) ++ :digraph.out_neighbours(g, v)
    |> Enum.reject(&(&1 === parent))
    Enum.reduce_while(vs, {pre, low}, fn other, {pre, low} ->
      case pre do
        %{^other => pre_other} ->
          low = Map.put(low, v, min(Map.fetch!(low, v), pre_other))
          {:cont, {pre, low}}
        %{} ->
          case find_bridge(g, v, other, pre, low) do
            {pre, low} ->
              low = Map.put(low, v, min(Map.fetch!(low, v), Map.fetch!(low, other)))
              if Map.fetch!(low, other) === Map.fetch!(pre, other) do
                {:halt, {:bridge, v, other}}
              else
                {:cont, {pre, low}}
              end
            {:bridge, _, _} = bridge ->
              {:halt, bridge}
          end
      end
    end)
  end

  def part2(input) do
    parse(input)
  end

  defp parse(input) do
    g = :digraph.new
    input
    |> Enum.map(fn line ->
      String.split(line, [":", " "], trim: true)
      |> Enum.map(&String.to_atom/1)
    end)
    |> Enum.each(fn [component | components] ->
      :digraph.add_vertex(g, component)
      Enum.each(components, fn c ->
        :digraph.add_vertex(g, c)
        :digraph.add_edge(g, {c,component}, c, component, [])
      end)
    end)
    g
  end
end
