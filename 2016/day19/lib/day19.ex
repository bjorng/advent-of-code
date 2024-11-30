defmodule Day19 do
  def part1(size) do
    list = Enum.map(1..size, &(&1))
    play_part1([], list)
  end

  def part2(size) do
    middle = div(size, 2)
    f = fn index -> {index, index} end
    left = Enum.map(middle+1..size, f)
    right = Enum.map(1..middle, f)
    play_part2(:gb_trees.from_orddict(left), :gb_trees.from_orddict(right))
  end

  defp play_part1(left, [current, _stolen | right]) do
    left = [current | left]
    play_part1(left, right)
  end
  defp play_part1(left, right) do
    case right ++ Enum.reverse(left) do
      [winner] -> winner
      right -> play_part1([], right)
    end
  end

  # Invariants: The current elf is the lowest element in the `right` tree.
  # He will steal from the lowest element in the `left` tree.
  # The `left` tree has the same number of elements or one more element than
  # the `right` tree.
  defp play_part2(left, right) do
    case :gb_trees.is_empty(right) do
      true ->
        [{_, winner}] = :gb_trees.to_list(left)
        winner
      false ->
        {_, current, right} = :gb_trees.take_smallest(right)
        {_, _stolen, left} = :gb_trees.take_smallest(left)
        left = insert_last(current, left)
        case :gb_trees.size(left) - :gb_trees.size(right) === 2 do
          true ->
            {_, id, left} = :gb_trees.take_smallest(left)
            right = insert_last(id, right)
            play_part2(left, right)
          false ->
            play_part2(left, right)
        end
    end
  end

  defp insert_last(id, tree) do
    case :gb_trees.is_empty(tree) do
      true ->
        :gb_trees.insert(1, id, tree)
      false ->
        {largest, _} = :gb_trees.largest(tree)
        :gb_trees.insert(largest + 1, id, tree)
    end
  end
end
