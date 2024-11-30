defmodule Day22 do
  def part1(input) do
    nodes = parse(input)

    nodes
    |> Enum.map(fn {name1, used, _avail} ->
      case used do
        0 ->
          0
        _ ->
          Enum.count(nodes, fn {name2, _used, avail} ->
            name1 !== name2 and used <= avail
          end)
      end
    end)
    |> Enum.sum
  end

  def part2(input) do
    grid = parse(input)
    max_x = Enum.map(grid, fn {{x, _}, _, _} -> x end)
    |> Enum.max
    goal = {max_x, 0}
    {empty, _, empty_avail} = Enum.find(grid, fn {_, used, _} -> used === 0 end)

    grid = grid
    |> Enum.reduce([], fn {id, used, _avail}, acc ->
      if used > empty_avail do
        acc
      else
        [id | acc]
      end
    end)
    |> MapSet.new

    state = {goal, empty}
    print_grid(grid, state)
    astar_search(state, grid)
  end

  defp astar_search(state, grid) do
    q = q_init(state)
    seen = MapSet.new()
    astar(q, grid, seen)
  end

  defp astar(q, grid, seen) do
    {turns, state, q} = q_get(q)
    case new_states(state, grid) do
      states when is_list(states) ->
        states =
          Enum.reject(states, fn {state, _} ->
            MapSet.member?(seen, state)
          end)
        seen = Enum.reduce(states, seen, fn {state, _}, acc ->
          MapSet.put(acc, state)
        end)
        turns = turns + 1
        q = Enum.reduce(states, q, fn {state, heuristic}, q ->
          {a, b} = state
          true = a !== b
          q_add(q, heuristic, turns, state)
        end)
        astar(q, grid, seen)
      :done ->
        turns
    end
  end

  defp new_states({goal, empty}, grid) do
    true = goal !== empty
    target = {0, 0}
    if target === goal do
      :done
    else
      move_goal(goal, empty, grid) ++
        move_empty(goal, empty, grid)
      |> Enum.uniq
    end
  end

  defp move_goal(goal, empty, grid) do
    neighbors(goal, grid)
    |> Enum.flat_map(fn position ->
      case position do
        ^empty ->
          [{{position, goal}, manhattan_distance(position, {0, 0})}]
        _ ->
          []
      end
    end)
  end

  defp move_empty(goal, empty, grid) do
    neighbors(empty, grid)
    |> Enum.map(fn position ->
      case position do
        ^goal ->
          {{position, empty}, min(manhattan_distance(position, goal),
             manhattan_distance(position, {0, 0}))}
        _ ->
          {{goal, position}, min(manhattan_distance(position, goal),
             manhattan_distance(position, {0, 0}))}
      end
    end)
  end

  defp manhattan_distance({x0, y0}, {x1, y1}) do
    abs(x0 - x1) + abs(y0 - y1)
  end

  defp q_init(initial) do
    :gb_sets.singleton({0, 0, initial})
  end

  defp q_get(q) do
    {{_, turns, state}, q} = :gb_sets.take_smallest(q)
    {turns, state, q}
  end

  defp q_add(q, heuristic, turns, state) do
    priority = turns + heuristic
    :gb_sets.insert({priority, turns, state}, q)
  end

  defp neighbors({x, y}, grid) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
    |> Enum.filter(fn position ->
      MapSet.member?(grid, position)
    end)
  end

  defp print_grid(grid, {goal, empty}) do
    IO.puts ""
    max_x = Enum.map(grid, fn {x, _} -> x end) |> Enum.max
    max_y = Enum.map(grid, fn {_, y} -> y end) |> Enum.max
    0..max_y
    |> Enum.reduce(nil, fn y, _ ->
      Enum.map(0..max_x, fn x ->
        pos = {x, y}
        case MapSet.member?(grid, pos) do
          true ->
            case pos do
              ^goal -> ?G
              ^empty -> ?_
              _ -> ?.
            end
          false -> ?\#
        end
      end)
      |> IO.puts
    end)
  end

  defp parse(input) do
    ["root@ebhq" <> _, "Filesystem" <> _ | nodes] = input
    Enum.map(nodes, fn line ->
      String.split(line, " ", trim: true)
      |> Enum.map(fn field ->
        case Integer.parse(field) do
          :error -> field
          {int, "T"} -> int
          {int, "%"} -> int
        end
      end)
      |> simplify_node
    end)
  end

  defp simplify_node([name, _, used, avail, _]) do
    [_, <<?x, x::binary>>, <<?y, y::binary>>] = String.split(name, "-")
    {{String.to_integer(x), String.to_integer(y)}, used, avail}
  end
end
