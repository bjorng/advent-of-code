defmodule Day17 do
  import Bitwise

  def part1(input) do
    solve(input, 2022)
  end

  def part2(input) do
    solve(input, 1_000_000_000_000)
  end

  defp solve(input, limit) do
    jets = parse(input)
    jets = {jets, jets}
    cave = cave()
    rocks = patterns()
    rocks = {rocks, rocks}
    blockage = %{}
    index = 0
    do_solve(cave, rocks, jets, blockage, index, limit)
  end

  defp do_solve(cave, rocks, jets, blockage, index, limit) do
    case index do
      ^limit ->
        tower_height(cave)
      _ ->
        case update_blockage(blockage, cave, jets, index) do
          {:done, diffs} ->
            result(diffs, index, limit, rocks, cave, jets)
          blockage ->
            {rock, rocks} = next_rock(rocks)
            {cave, jets} = drop_rock(rock, cave, jets)
            do_solve(cave, rocks, jets, blockage, index + 1, limit)
        end
    end
  end

  defp next_rock({[rock | rocks], all_rocks}) do
    {rock, {rocks, all_rocks}}
  end
  defp next_rock({[], all_rocks}), do: next_rock({all_rocks, all_rocks})

  defp result({index_diff, height_diff}, index, limit, rocks, cave, jets) do
    remaining = limit - index
    extra_height = div(remaining, index_diff) * height_diff
    remaining = rem(remaining, index_diff)
    {_, cave, _} = Enum.reduce(1..remaining//1, {rocks, cave, jets}, fn _, {rocks, cave, jets} ->
      {rock, rocks} = next_rock(rocks)
      {cave, jets} = drop_rock(rock, cave, jets)
      {rocks, cave, jets}
    end)
    tower_height(cave) + extra_height
  end

  defp update_blockage(blockage, cave_rows, jets, index) do
    case find_blockage(cave_rows, 0) do
      nil ->
        blockage
      blocker ->
        height = length(cave_rows)
        key = {blocker, rem(index, 5), length(elem(jets, 0))}
        case blockage do
          %{^key => {previous_height, previous_index}} ->
            height_diff = height - previous_height
            index_diff = index - previous_index
            {:done, {index_diff, height_diff}}
          %{} ->
            Map.put(blockage, key, {height, index})
        end
    end
  end

  defp find_blockage([], _), do: nil
  defp find_blockage([_], _), do: nil
  defp find_blockage([h1, h2 | tail], n) do
    if (h1 ||| h2) === 127 and tail !== []  do
      {n, h1, h2}
    else
      find_blockage([h2 | tail], n + 1)
    end
  end

  defp drop_rock(rock, cave, jets) do
    do_drop_rock(jets, rock, prepare_cave(cave, rock))
  end

  defp do_drop_rock({[], all_jets}, rock, cave) do
    do_drop_rock({all_jets, all_jets}, rock, cave)
  end
  defp do_drop_rock({[jet | jets], all_jets}, rock, cave) do
    jets = {jets, all_jets}
    moved_rock = shift_rock(rock, jet)

    rock = case are_disjoint?(cave, moved_rock) do
             true ->
               moved_rock
             false ->
               rock
           end

    new_cave = move_down(cave)
    case are_disjoint?(new_cave, rock) do
      true ->
        do_drop_rock(jets, rock, new_cave)
      false ->
        {rows, passed} = cave
        {_, _, rock_rows} = rock
        rows = combine(rows, rock_rows)
        rows = Enum.reverse(passed, rows)
        |> Enum.drop_while(&(&1 === 0))
        {rows, jets}
    end
  end

  defp prepare_cave(rows, {_, _, rock_rows}) do
    rows = List.duplicate(0, length(rock_rows) + 3) ++ rows
    passed = []
    {rows, passed}
  end

  defp move_down({[row | rows], passed}) do
    passed = [row | passed]
    {rows, passed}
  end

  defp combine(rows, []), do: rows
  defp combine([row1 | rows1], [row2 | rows2]) do
    [row1 ||| row2 | combine(rows1, rows2)]
  end

  defp are_disjoint?({rows, _passed}, {_, _, rock_rows}) do
    do_are_disjoint?(rows, rock_rows)
  end

  defp do_are_disjoint?([_row | _rows], []), do: true
  defp do_are_disjoint?([row | rows], [rock_row | rock_rows]) do
    case row &&& rock_row do
      0 ->
        do_are_disjoint?(rows, rock_rows)
      _ ->
        false
    end
  end

  defp cave() do
    [0b111_1111]
  end

  defp tower_height(rows) do
    length(rows) - 1
  end

  defp patterns() do
    [
      {1, 4,
       [0b0011110]},

      {2, 3,
       [0b0001000,
        0b0011100,
        0b0001000]},

      {2, 3,
       [0b0000100,
        0b0000100,
        0b0011100]},

      {4, 1,
       [0b0010000,
        0b0010000,
        0b0010000,
        0b0010000]},

      {3, 2,
       [0b0011000,
        0b0011000]}
    ]
  end

  defp shift_rock(rock, direction) do
    case {rock, direction} do
      {{right, width, contents}, :left} when right + width < 7  ->
        {right + 1, width, Enum.map(contents, &(&1 <<< 1))}
      {{right, width, contents}, :right} when right > 0 ->
        {right - 1, width, Enum.map(contents, &(&1 >>> 1))}
      {_, _} ->
        rock
    end
  end

  defp parse(input) do
    input
    |> hd
    |> String.to_charlist
    |> Enum.map(fn char ->
      case char do
        ?< -> :left
        ?> -> :right
      end
    end)
  end

  def print_cave(rows) when is_list(rows) do
    IO.puts ""
    Enum.each(rows, fn row ->
      Enum.map(7..-1//-1, fn x ->
        case (row >>> x) &&& 1 do
          0 when x in 0..6 -> ?.
          0 -> ?|
          1 -> ?\#
        end
      end)
      |> IO.puts
    end)
  end
end
