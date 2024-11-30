defmodule Day17 do
  def part1(salt) do
    find_shortest_path({0, 0}, {3, 3}, salt)
  end

  def part2(salt) do
    find_longest_path({0, 0}, {3, 3}, salt)
  end

  defp find_shortest_path(from, goal, salt) do
    q = q_init(from)
    {path, _} = find_path(q, goal, salt)
    path
  end

  defp find_longest_path(from, goal, salt) do
    q = q_init(from)
    find_longest_path(q, goal, salt, nil)
  end

  defp find_longest_path(q, goal, salt, longest) do
    case find_path(q, goal, salt) do
      nil ->
        longest
      {path, q} ->
        find_longest_path(q, goal, salt, byte_size(path))
    end
  end

  defp find_path(q, goal, salt) do
    case q_get(q) do
      nil ->
        nil
      {_cost, ^goal, path, q} ->
        {List.to_string(path), q}
      {cost, position, path, q} ->
        ns = neighbors(position, salt, path)
        cost = cost + 1
        q = Enum.reduce(ns, q, fn {dir, position}, q ->
          q_add(q, cost, position, [path, dir])
        end)
        find_path(q, goal, salt)
    end
  end

  defp q_init(from) do
    :gb_trees.from_orddict([{{0, []}, from}])
  end

  defp q_get(q) do
    case :gb_trees.is_empty(q) do
      true ->
        nil
      false ->
        {{cost, path}, position, q} = :gb_trees.take_smallest(q)
        {cost, position, path, q}
    end
  end

  defp q_add(q, cost, position, path) do
    :gb_trees.insert({cost, path}, position, q)
  end

  defp neighbors({r, c}, salt, path) do
    hash = :erlang.md5([salt | path])
    <<up::size(4), dn::size(4), lt::size(4), rt::size(4), _::binary>> = hash
    [{up, ?U, {r - 1, c}},
     {dn, ?D, {r + 1, c}},
     {lt, ?L, {r, c - 1}},
     {rt, ?R, {r, c + 1}}]
     |> Enum.filter(fn {door, _dir, {r, c}} ->
      door >= 0xb and r in 0..3 and c in 0..3
    end)
    |> Enum.map(fn {_, dir, position} -> {dir, position} end)
  end
end
