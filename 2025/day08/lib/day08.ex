defmodule Day08 do
  def part1(input, n) do
    boxes = parse(input)
    boxes
    |> make_pairs
    |> Enum.take(n)
    |> group_part1(boxes)
    |> Enum.map(fn {_, {_, size}} -> size end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product
  end

  defp group_part1(pairs, boxes) do
    forest = union_find_init(boxes)
    Enum.reduce(pairs, forest, fn pair, forest ->
      {_done?, forest} = add_pair(forest, pair)
      forest
    end)
  end

  def part2(input) do
    boxes = parse(input)
    boxes
    |> make_pairs
    |> group_part2(boxes)
    |> then(fn {{x1, _, _}, {x2, _, _}} ->
      x1 * x2
    end)
  end

  defp group_part2(pairs, boxes) do
    forest = union_find_init(boxes)
    Enum.reduce_while(pairs, forest, fn pair, forest ->
      {done?, forest} = add_pair(forest, pair)
      case done? do
        true ->
          {:halt, pair}
        false ->
          {:cont, forest}
      end
    end)
  end

  defp make_pairs(boxes) do
    boxes
    |> Enum.flat_map(fn a ->
      Enum.flat_map(boxes, fn b ->
        if a < b do
          [{squared_distance(a, b), {a, b}}]
        else
          []
        end
      end)
    end)
    |> Enum.sort
    |> Enum.map(&elem(&1, 1))
  end

  defp squared_distance({x1, y1, z1}, {x2, y2, z2}) do
    xd = x1 - x2
    yd = y1 - y2
    zd = z1 - z2
    xd * xd + yd * yd + zd * zd
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> then(&List.to_tuple/1)
    end)
  end

  # Here follows an implementation of the union-find data structure.
  defp union_find_init(points) do
    points
    |> Enum.map(&{&1, {&1, 1}})
    |> Map.new
  end

  defp add_pair(forest, {a, b}) do
    pa = find(forest, a)
    pb = find(forest, b)
    if pa === pb do
      {false, forest}
    else
      union(forest, pa, pb)
    end
  end

  defp find(forest, p) do
    case forest do
      %{^p => {^p, _}} ->
        p
      %{^p => {parent, _}} ->
        find(forest, parent)
    end
  end

  defp union(forest, a, b) do
    {_, size_a} = Map.get(forest, a)
    {_, size_b} = Map.get(forest, b)
    size = size_a + size_b

    forest = if size_a > size_b do
      Map.put(forest, b, {a, size_b})
      |> Map.put(a, {a, size})
    else
      Map.put(forest, a, {b, size_a})
      |> Map.put(b, {b, size})
    end

    done? = size === map_size(forest)
    {done?, forest}
  end
end
