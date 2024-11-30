defmodule Day08 do
  def part1(lines) do
    lines
    |> Enum.map(&String.to_integer/1)
    |> (fn list -> {tree, []} = build_tree(list); tree end).()
    |> sum_meta(0)
  end

  defp sum_meta {meta, children}, sum do
    sum = sum + Enum.sum(meta)
    Enum.reduce(children, sum, &sum_meta/2)
  end

  defp build_tree [num_children, num_meta | t] do
    {children, t} = build_tree_children(t, num_children, [])
    {meta, t} = Enum.split(t, num_meta)
    {{meta, children}, t}
  end

  defp build_tree_children t, 0, acc do
    {Enum.reverse(acc), t}
  end

  defp build_tree_children t, num_children, acc do
    {tree, t} = build_tree(t)
    build_tree_children t, num_children - 1, [tree | acc]
  end

  def part2(lines) do
    lines
    |> Enum.map(&String.to_integer/1)
    |> (fn list -> {tree, []} = build_tree(list); tree end).()
    |> value()
  end

  defp value {meta, []} do
    Enum.sum(meta)
  end

  defp value {meta, children} do
    Enum.reduce(meta, 0, fn m, acc -> sum_one_meta(m, children, acc) end)
  end

  defp sum_one_meta(0, _children, acc), do: acc

  defp sum_one_meta index, children, acc do
    case take_index(children, index) do
      nil ->
	acc
      child ->
	acc + value(child)
    end
  end

  defp take_index([h | _], 1), do: h
  defp take_index([_ | t], index), do: take_index t, index - 1
  defp take_index([], _index), do: nil

end
