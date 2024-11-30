defmodule Day08 do
  def part1(input) do
    {directions, node_map} = parse(input)
    Stream.cycle(directions)
    count_steps(:AAA, [:ZZZ], directions, node_map)
  end

  def part2(input) do
    {directions, node_map} = parse(input)
    start_nodes = match_nodes(node_map, ?A)
    end_nodes = Enum.sort(match_nodes(node_map, ?Z))
    Enum.map(start_nodes, fn node ->
      count_steps(node, end_nodes, directions, node_map)
    end)
    |> Enum.reduce(1, fn n, lcd ->
      div(n * lcd, Integer.gcd(n, lcd))
    end)
  end

  defp count_steps(start_node, end_nodes, directions, node_map) do
    Stream.cycle(directions)
    |> Enum.reduce_while({start_node, 0}, fn dir, {node, count} ->
      next = case {dir, node_map[node]} do
               {?L, {left, _}} -> left
               {?R, {_, right}} -> right
             end
      case Enum.member?(end_nodes, next) do
        true -> {:halt, count + 1}
        false -> {:cont, {next, count + 1}}
      end
    end)
  end

  defp match_nodes(node_map, char) do
    node_map
    |> Map.keys
    |> Enum.filter(fn node ->
      [_,_,last] = Atom.to_charlist(node)
      last === char
    end)
  end

  defp parse(input) do
    [directions | nodes] = input
    nodes = nodes
    |> Enum.map(fn line ->
      String.split(line, [" ", "=", "(", ")", ","], trim: true)
      |> Enum.map(&String.to_atom/1)
      |> then(fn [node, left, right] ->
        {node, {left, right}}
      end)
    end)
    {String.to_charlist(directions), Map.new(nodes)}
  end
end
