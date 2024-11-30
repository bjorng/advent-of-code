defmodule Day13 do
  use Bitwise

  def part1(input, goal \\ {31, 39}) do
    astar_search({1, 1}, goal, grid_type_fn(input))
  end

  def part2(input, max_steps \\ 50) do
    reachable(max_steps, {1, 1}, grid_type_fn(input))
  end

  #
  # Part 1.
  #

  defp astar_search(from, goal, grid_type) do
    q = q_init(from)
    seen = MapSet.new()
    astar(q, goal, grid_type, seen)
  end

  defp astar(q, goal, grid_type, seen) do
    case q_get(q) do
      {turns, ^goal, _q} ->
        turns
      {turns, position, q} ->
        ns = neighbors(position, grid_type)
        |> Enum.reject(&MapSet.member?(seen, &1))

        seen = Enum.reduce(ns, seen, fn neighbor, acc ->
          MapSet.put(acc, neighbor)
        end)

        turns = turns + 1
        q = Enum.reduce(ns, q, fn position, q ->
          h = heuristic(goal, position)
          priority = turns + h
          q_add(q, priority, turns, position)
        end)

        astar(q, goal, grid_type, seen)
    end
  end

  defp heuristic({x0, y0}, {x1, y1}) do
    abs(x0 - x1) + abs(y0 - y1)
  end

  defp q_init(from) do
    :gb_sets.singleton({0, 0, from})
  end

  defp q_get(q) do
    {{_, turns, position}, q} = :gb_sets.take_smallest(q)
    {turns, position, q}
  end

  defp q_add(q, priority, turns, position) do
    :gb_sets.insert({priority, turns, position}, q)
  end

  #
  # Part 2.
  #

  defp reachable(max_steps, from, grid_type) do
    seen = MapSet.new([from])
    reachable(max_steps, [from], grid_type, seen)
  end

  defp reachable(0, _positions, _grid_type, seen), do: MapSet.size(seen)
  defp reachable(steps, positions, grid_type, seen) do
    {positions, seen} = iter_reachable(positions, grid_type, seen, [])
    reachable(steps - 1, positions, grid_type, seen)
  end

  defp iter_reachable([], _grid_type, seen, acc), do: {acc, seen}
  defp iter_reachable([position | positions], grid_type, seen, acc) do
    ns = neighbors(position, grid_type)
    |> Enum.reject(&MapSet.member?(seen, &1))
    seen = Enum.reduce(ns, seen, fn neighbor, acc ->
      MapSet.put(acc, neighbor)
    end)
    iter_reachable(positions, grid_type, seen, ns ++ acc)
  end

  #
  # Common utilities.
  #

  defp neighbors({x, y}, grid_type) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
    |> Enum.filter(fn {x, y} = position ->
      x >= 0 and y >= 0 and grid_type.(position) == :open
    end)
  end

  defp grid_type_fn(favorite) do
    fn {x, y} ->
      e = x * x + 3*x + 2*x*y + y + y*y + favorite
      case count_ones(e) &&& 1 do
        0 -> :open
        1 -> :wall
      end
    end
  end

  def count_ones(n), do: count_ones(n, 0)

  def count_ones(0, count), do: count
  def count_ones(n, count), do: count_ones(n &&& (n - 1), count + 1)
end
