defmodule Day24 do
  def part1(input) do
    {start_pos, goals, grid} = parse(input)
    find_single_solution({start_pos, goals}, grid)
  end

  def part2(input) do
    {start_pos, goals, grid} = parse(input)
    find_all_solutions({start_pos, goals}, grid)
    |> Enum.map(fn {moves0, position} ->
      goals = MapSet.new([start_pos])
      {moves, _, _, _} = astar_search({position, goals}, grid)
      moves0 + moves
    end)
    |> Enum.min
  end

  defp find_single_solution(initial, grid) do
    {moves, _, _, _} = astar_search(initial, grid)
    moves
  end

  defp find_all_solutions(from, grid) do
    q = q_init(from)
    find_all_solutions(q, grid, MapSet.new())
  end

  defp find_all_solutions(q, grid, seen) do
    case astar(q, grid, seen) do
      nil ->
        []
      {moves, position, seen, q} ->
        [{moves, position} | find_all_solutions(q, grid, seen)]
    end
  end

  defp astar_search(from, grid) do
    q = q_init(from)
    seen = MapSet.new()
    astar(q, grid, seen)
  end

  defp astar(q, grid, seen) do
    case q_get(q) do
      nil ->
        nil
      {moves, {position, goals}, q} ->
        case MapSet.size(goals) do
          0 ->
            {moves, position, seen, q}
          _ ->
            ns = neighbors(position, grid)
            |> Enum.reject(&MapSet.member?(seen, {&1, goals}))

            seen = Enum.reduce(ns, seen, fn neighbor, acc ->
              MapSet.put(acc, {neighbor, goals})
            end)

            moves = moves + 1
            q = Enum.reduce(ns, q, fn position, q ->
              goals = MapSet.delete(goals, position)
              heuristic = 0
              priority = moves + heuristic
              q_add(q, priority, moves, {position, goals})
            end)

            astar(q, grid, seen)
        end
    end
  end

  defp q_init(from) do
    :gb_sets.singleton({0, 0, from})
  end

  defp q_get(q) do
    case :gb_sets.is_empty(q) do
      true ->
        nil
      false ->
        {{_, moves, position}, q} = :gb_sets.take_smallest(q)
        {moves, position, q}
    end
  end

  defp q_add(q, priority, moves, position) do
    :gb_sets.insert({priority, moves, position}, q)
  end

  defp neighbors({x, y}, grid) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
    |> Enum.filter(fn position ->
      MapSet.member?(grid, position)
    end)
  end

  defp parse(input) do
    input = Enum.map(input, &String.to_charlist/1)

    grid = input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, r} ->
      line
      |> Enum.with_index
      |> Enum.map(fn {char, c} ->
        {{r, c}, char}
      end)
    end)

    groups = Enum.group_by(grid, fn {_pos, char} ->
      if char in ?0..?9, do: ?0, else: char
    end)

    {start_pos, _} = List.keyfind(groups[?0], ?0, 1)

    digits = groups[?0]
    |> Enum.map(fn {pos, _digit} -> pos end)
    |> MapSet.new
    |> MapSet.delete(start_pos)

    grid = groups[?0] ++ groups[?.]
    |> Enum.map(&(elem(&1, 0)))
    |> MapSet.new

    {start_pos, digits, grid}
  end
end
