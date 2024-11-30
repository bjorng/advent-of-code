defmodule Day09 do
  def part1(input) do
    solve(input, 2)
  end

  def part2(input) do
    solve(input, 10)
  end

  defp solve(input, num_knots) do
    knots = List.duplicate({0, 0}, num_knots)
    parse(input)
    |> Enum.flat_map(fn {direction, steps} ->
      List.duplicate(direction, steps)
    end)
    |> Enum.map_reduce(knots, fn direction, [head | knots] ->
      head = add(head, direction)
      knots = move_knots(knots, head)
      {List.last(knots), [head | knots]}
    end)
    |> elem(0)
    |> Enum.uniq
    |> Enum.count
  end

  defp move_knots(knots, head) do
    Enum.map_reduce(knots, head, fn knot, head ->
      knot = move_knot(knot, head)
      {knot, knot}
    end)
    |> elem(0)
  end

  defp move_knot(knot, head) do
    case are_touching?(knot, head) do
      true ->
        knot
      false ->
        knot = follow_head(knot, head)
        true = are_touching?(knot, head)
        knot
    end
  end

  defp are_touching?({row1, col1}, {row2, col2}) do
    abs(row1 - row2) <= 1 and abs(col1 - col2) <=1
  end

  defp follow_head({row_tl, col_tl}, {row_hd, col_hd}) do
    {row_tl + sign(row_hd - row_tl), col_tl + sign(col_hd - col_tl)}
  end

  defp sign(n) do
    cond do
      n < 0 -> -1
      n == 0 -> 0
      n > 0 -> 1
    end
  end

  defp add({row, col}, {delta_row, delta_col}) do
    {row + delta_row, col + delta_col}
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [direction, steps] = String.split(line)
      {case direction do
         "U" -> {-1, 0}
         "D" -> {1, 0}
         "L" -> {0, -1}
         "R" -> {0, 1}
       end,
       String.to_integer(steps)}
    end)
  end
end
