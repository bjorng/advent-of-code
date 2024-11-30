defmodule Day23 do
  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def part1(input) do
    df = fn grid, position ->
      case Map.fetch!(grid, position) do
        ?< -> [{0, -1}]
        ?> -> [{0, 1}]
        ?^ -> [{-1, 0}]
        ?v -> [{1, 0}]
        _ -> @directions
      end
    end
    solve(input, df)
  end

  def part2(input) do
    df = fn _grid, _position -> @directions end
    solve(input, df)
  end

  def solve(input, df) do
    {start, target, grid} = parse(input)
    g = build_graph(grid, df, target)
    seen = MapSet.new()
    find_longest_path(start, seen, 0, g, target)
  end

  defp find_longest_path(position, seen, steps, g, target) do
    if position === target do
      steps
    else
      ns = Map.fetch!(g, position)
      |> Enum.reject(fn {vertex, _weight} ->
        MapSet.member?(seen, vertex)
      end)

      seen = Enum.reduce(ns, seen, fn {vertex, _weight}, seen ->
        MapSet.put(seen, vertex)
      end)

      Enum.reduce(ns, steps, fn {vertex, weight}, acc ->
        max(acc, find_longest_path(vertex, seen, steps + weight, g, target))
      end)
    end
  end

  defp build_graph(grid, df, {row, _}) do
    rr = 0..row
    Enum.flat_map(grid, fn {position, what} ->
      if what === ?\# do
        []
      else
        [df.(grid, position)
        |> Enum.map(&add(position, &1))
        |> Enum.filter(fn {row, _col} = pos ->
           row in rr and Map.fetch!(grid, pos) !== ?\#
         end)
        |> Enum.map(&{&1, 1})
        |> then(&{position, &1})]
      end
    end)
    |> Map.new
    |> reduce_graph
  end

  defp reduce_graph(g) do
    case do_reduce_graph(g) do
      ^g -> g
      g -> reduce_graph(g)
    end
  end

  defp do_reduce_graph(g) do
    Enum.reduce(g, g, fn {v, _}, g ->
      case g do
        %{^v => ns} ->
          {ns, g} =
            Enum.map_reduce(ns, g, fn edge, g ->
              reduce_edge(edge, v, g) || {edge, g}
            end)
          Map.put(g, v, ns)
        %{} ->
          g
      end
    end)
  end

  defp reduce_edge({v0, w0}, v, g) do
    case g do
      %{^v0 => [{^v, ^w0} = this_edge, other_edge]} ->
        do_reduce_edge(v0, this_edge, other_edge, g)
      %{^v0 => [other_edge, {^v, ^w0} = this_edge]} ->
        do_reduce_edge(v0, this_edge, other_edge, g)
      %{} ->
        nil
    end
  end

  defp do_reduce_edge(v0, {v, w0}, {other, w1}, g) do
    g = Map.delete(g, v0)
    case fix_edge(other, v0, {v, w0 + w1}, g) do
      nil ->
        nil
      g ->
        {{other, w0 + w1}, g}
    end
  end

  defp fix_edge(v, other, new_edge, g) do
    case Map.get(g, v) do
      [{^other, _weight}, edge] ->
        Map.put(g, v, [new_edge, edge])
      [edge, {^other, _weight}] ->
        Map.put(g, v, [edge, new_edge])
      _ ->
        nil
    end
  end

  defp add({row0, col0}, {row1, col1}) do
    {row0 + row1, col0 + col1}
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> Map.new
    |> then(fn map ->
      {max_row, _} = Enum.max_by(Map.keys(map), &elem(&1, 0))
      {_, max_col} = Enum.max_by(Map.keys(map), &elem(&1, 1))
      ^max_row = max_col
      {{0, 1}, {max_row, max_col - 1}, map}
    end)
  end
end
