defmodule Day06 do
  def part1(input) do
    map = parse(input)
    Map.keys(map)
    |> Enum.map(fn object -> count_orbits(map, object) end)
    |> Enum.sum
  end

  def part2(input) do
    map = parse(input)
    g = make_digraph(map)
    you_orbiting = Map.fetch!(map, "YOU")
    santa_orbiting = Map.fetch!(map, "SAN")
    length(:digraph.get_path(g, you_orbiting, santa_orbiting)) - 1
  end

  defp count_orbits(map, object, orbits \\ 0) do
    case map do
      %{^object => around} ->
	count_orbits(map, around, orbits + 1)
      %{} ->
	orbits
    end
  end

  defp make_digraph(map) do
    g = :digraph.new()
    Enum.each(Map.to_list(map), fn {obj1, obj2} ->
      :digraph.add_vertex(g, obj1)
      :digraph.add_vertex(g, obj2)
      :digraph.add_edge(g, obj1, obj2)
      :digraph.add_edge(g, obj2, obj1)
    end)
    g
  end

  defp parse(input) do
    Map.new(Enum.map(input, &parse_pair/1))
  end

  defp parse_pair(line) do
    [x, y] = String.split(line, ")")
    {y, x}
  end
end
