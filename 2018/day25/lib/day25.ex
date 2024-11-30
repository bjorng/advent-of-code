defmodule Day25 do
  def part1(lines) do
    coords = parse(lines)
    constellations = find_constellations(coords)
    length(constellations)
  end

  defp find_constellations(coords) do
    digraph = build_digraph(coords)
    res = :digraph_utils.components(digraph)
    :digraph.delete(digraph)
    res
  end

  defp build_digraph(coords) do
    digraph = :digraph.new()
    Enum.each(coords, fn coord ->
      :digraph.add_vertex(digraph, coord)
    end)
    build_digraph(Enum.sort(coords), digraph)
  end

  defp build_digraph([coord | coords], digraph) do
    add_edges(coords, coord, digraph)
    build_digraph(coords, digraph)
  end

  defp build_digraph([], digraph), do: digraph

  defp add_edges([coord | coords], coord0, digraph) do
    if manhattan_distance(coord, coord0) <= 3 do
      :digraph.add_edge(digraph, coord0, coord)
    end
    add_edges(coords, coord0, digraph)
  end

  defp add_edges([], _coord0, digraph), do: digraph

  defp manhattan_distance({x0, y0, z0, w0}, {x, y, z, w}) do
    abs(x0 - x) + abs(y0 - y) + abs(z0 - z) + abs(w0 - w)
  end

  defp parse(lines) do
    Enum.map(lines, &parse_line/1)
  end

  defp parse_line(line) do
    String.split(line, ",")
    |> Enum.map(&String.to_integer/1)
    |> (fn list -> List.to_tuple(list) end).()
  end
end
