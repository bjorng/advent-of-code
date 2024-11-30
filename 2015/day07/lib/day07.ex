defmodule Day07 do
  use Bitwise

  def part1(input) do
    parse(input)
    |> solve
  end

  def part2(input) do
    input = parse(input)
    b_value = solve(input)[:a]
    List.keyreplace(input, :b, 1, {:OR, :b, [b_value, 0]})
    |> solve
  end

  defp solve(instructions) do
    instructions
    |> top_sort_input
    |> Enum.reduce(%{}, &execute/2)
  end

  defp top_sort_input(ops) do
    op_map = ops
    |> Enum.map(fn {_, dst, _} = op ->
      {dst, op}
    end)
    |> Map.new

    ops
    |> Enum.flat_map(fn {_, dst, sources} ->
      Enum.filter(sources, &is_atom/1)
      |> Enum.map(&({&1, dst}))
    end)
    |> top_sort
    |> Enum.map(&(Map.fetch!(op_map, &1)))
  end

  defp top_sort(deps) do
    {counts, successors} = top_sort_1(deps, %{}, %{})
    q = Enum.flat_map(counts,
      fn {key, 0} -> [key];
        _ -> []
      end)
      |> :queue.from_list
    top_sort_2(q, counts, successors, [])
  end

  defp top_sort_1([{pred,succ}|deps], counts, successors) do
    counts = Map.update(counts, pred, 0, &(&1))
    counts = Map.update(counts, succ, 1, &(&1 + 1))
    successors = Map.update(successors, pred, [succ], &([succ|&1]))
    top_sort_1(deps, counts, successors)
  end
  defp top_sort_1([], counts, successors), do: {counts, successors}

  defp top_sort_2(q, counts, successors, acc) do
    case :queue.out(q) do
      {:empty, _} ->
        Enum.reverse(acc)
      {{:value,item}, q} ->
        {counts, q} = top_sort_update(Map.get(successors, item, []), counts, q)
        top_sort_2(q, counts, successors, [item|acc])
    end
  end

  defp top_sort_update([item|items], counts, q) do
    case Map.get_and_update!(counts, item, &({&1 - 1, &1 - 1})) do
      {0, counts} ->
        q = :queue.in(item, q)
        top_sort_update(items, counts, q)
      {_, counts} ->
        top_sort_update(items, counts, q)
    end
  end
  defp top_sort_update([], counts, q), do: {counts, q}

  defp execute({op, dst, sources}, regs) do
    op = case op do
           :AND -> &band/2
           :OR -> &bor/2
           :NOT -> &((bnot &1) &&& 0xffff)
           :LSHIFT -> &<<</2
           :RSHIFT -> &>>>/2
         end
    sources = Enum.map(sources,
      fn src when is_integer(src) -> src
        src when is_atom(src) -> Map.get(regs, src, 0)
      end)
    Map.put(regs, dst, apply(op, sources))
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line)
      |> Enum.map(fn token ->
        case Integer.parse(token) do
          :error ->
            String.to_atom(token)
          {int, _} ->
            int
        end
      end)
    end)
    |> Enum.map(fn line ->
      case line do
        [:NOT, src, :->, dst] ->
          {:NOT, dst, [src]}
        [src, :->, wire] ->
          {:OR, wire, [src, 0]}
        [src1, op, src2, :->, dst] ->
          {op, dst, [src1, src2]}
      end
    end)
  end
end
