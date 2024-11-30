defmodule Day07 do
  def part1(stream) do
    {root, _nodes} = parse(stream)
    root
  end

  def part2(stream) do
    {root, nodes} = parse(stream)
    {tree, remaining} = build_tree(root, nodes)
    0 = map_size(remaining)
    balance(tree, nil)
  end

  defp balance({_, parent_weight, children}, offset) do
    weights = weights(children)
    freq = freq_map(weights)
    |> Map.to_list
    |> Enum.sort_by(&(elem(&1, 1)))

    case freq do
      [{bad_weight, 1}, {good_weight, _}] ->
        offset = good_weight - bad_weight
        bad = Enum.at(children, Enum.find_index(weights, & &1 == bad_weight))
        balance(bad, offset)
      [_] ->
        parent_weight + offset
    end
  end

  defp weights(list) do
    Enum.map(list, &tree_weight/1)
  end

  defp tree_weight({_name, weight, children}) do
    weights = Enum.map(children, &tree_weight/1)
    weight + Enum.sum(weights)
  end

  defp freq_map(enumerable) do
    Enum.reduce(enumerable, %{}, fn elem, acc ->
      Map.update(acc, elem, 1, & &1 + 1)
    end)
  end

  defp build_tree(root, nodes) do
    {{weight, children}, nodes} = Map.pop(nodes, root)
    {children, nodes} = Enum.map_reduce(children, nodes, &build_tree/2)
    {{root, weight, children}, nodes}
  end

  defp parse(stream) do
    nodes = stream
    |> Stream.map(&parse_line/1)
    |> Enum.to_list

    root_candidates = nodes
    |> Enum.map(& elem(&1, 0))
    |> MapSet.new

    root = Enum.reduce(nodes, root_candidates, fn {_, {_, children}}, acc ->
      Enum.reduce(children, acc, fn child, acc ->
        MapSet.delete(acc, child)
      end)
    end)

    [root] = MapSet.to_list(root)
    {root, Map.new(nodes)}
  end

  defp parse_line(line) do
    [name, "(" <> weight | children] =
      String.split(line, [" ", ", ", "->"], trim: true)
    {weight, ")"} = Integer.parse(weight)
    {name, {weight, children}}
  end
end
