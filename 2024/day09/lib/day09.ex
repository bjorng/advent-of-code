defmodule Day09 do
  def part1(input) do
    map = parse(input)
    first = 0
    {last,_} = Enum.max(map)
    move(map, first, last)
    |> Enum.sort
    |> Enum.flat_map(fn {_, {items, _}} -> items end)
    |> checksum
  end

  defp move(map, first, last) when last <= first, do: map
  defp move(map, first, last) do
    case map do
      %{^last => {items, _}} ->
        {map, first} = Map.delete(map, last)
        |> insert(first, items, length(items))
        move(map, first, last - 1)
    end
  end

  defp insert(map, first, [], 0), do: {map, first}
  defp insert(map, first, items, num_items) do
    case map do
      %{^first => {_keep, 0}} ->
        insert(map, first + 1, items, num_items)
      %{^first => {keep, num_free}} ->
        take = min(num_free, num_items)
        {fits, items} = Enum.split(items, take)
        num_free = num_free - take
        num_items = num_items - take
        map = Map.put(map, first, {keep ++ fits, num_free})
        first = if num_free === 0, do: first + 1, else: first
        insert(map, first, items, num_items)
      %{} ->
        first = first + 1
        {Map.put(map, first, {items, 0}), first}
    end
  end

  def part2(input) do
    map = parse(input)
    {last,_} = Enum.max(map)
    move_part2(map, last)
    |> Enum.sort
    |> Enum.flat_map(fn {_, {items, _}} -> items end)
    |> checksum
  end

  defp move_part2(map, 0) do
    {orig_items, num_free} = Map.fetch!(map, 0)
    items = orig_items ++ List.duplicate(0, num_free)
    Map.put(map, 0, {items, 0})
  end
  defp move_part2(map, last) do
    {orig_items, num_free} = Map.fetch!(map, last)
    items = Enum.filter(orig_items, &(&1 === last))
    n = length(items)
    case insert_part2(map, 0, last, items, n) do
      nil ->
        items = orig_items ++ List.duplicate(0, num_free)
        map = Map.put(map, last, {items, 0})
        move_part2(map, last - 1)
      map ->
        items =
          Enum.map(orig_items, fn item ->
            if item === last, do: 0, else: item
          end)
        items = items ++ List.duplicate(0, num_free)
        map = Map.put(map, last, {items, 0})
        move_part2(map, last - 1)
    end
  end

  defp insert_part2(_map, last, last, _items, _num_items), do: nil
  defp insert_part2(map, first, last, items, num_items) do
    {present, free} = Map.fetch!(map, first)
    if free < num_items do
      insert_part2(map, first + 1, last, items, num_items)
    else
      present = present ++ items
      Map.put(map, first, {present, free - num_items})
    end
  end

  defp checksum(blocks) do
    blocks
    |> Enum.with_index
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum
  end

  defp parse(input) do
    input
    |> hd
    |> String.to_charlist
    |> Enum.map(&(&1-?0))
    |> Enum.chunk_every(2)
    |> Enum.with_index
    |> Enum.map(fn {pair, index} ->
      case pair do
        [a, b] -> {index, {List.duplicate(index, a), b}}
        [a] -> {index, {List.duplicate(index, a), 0}}
      end
    end)
    |> Map.new
  end
end
