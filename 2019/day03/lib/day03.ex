defmodule Day03 do
  def part1(input) do
    find_all_crossings(input)
    |> Enum.min
    |> elem(0)
  end

  def part2(input) do
    find_all_crossings(input)
    |> Enum.map(fn {_, steps} -> steps end)
    |> Enum.min
  end

  defp find_all_crossings(input) do
    [wire1, wire2] = parse(input)
    find_crossings(horizontals(wire1), verticals(wire2)) ++
      find_crossings(horizontals(wire2), verticals(wire1))
  end

  defp horizontals(segments) do
    for {{{x1, y}, {x2, y}}, steps} <- segments do
      case x1 < x2 do
	true ->
	  {x1, x2, y, steps}
	false ->
	  {x2, x1, y, -steps}
      end
    end
  end

  defp verticals(segments) do
    for {{{x, y1}, {x, y2}}, steps} <- segments do
      case y1 < y2 do
	true ->
	  {y1, y2, x, steps}
	false ->
	  {y2, y1, x, -steps}
      end
    end
  end

  defp find_crossings(horizontals, verticals) do
    horizontals
    |> Enum.flat_map(fn hor ->
      Enum.flat_map(verticals, fn vert ->
	find_crossing(hor, vert)
      end)
    end)
  end

  defp find_crossing({hor_x1, hor_x2, hor_y, hor_steps} = hor,
	{vert_y1, vert_y2, vert_x, vert_steps} = vert) do
    case hor_x1 < vert_x and vert_x < hor_x2 and vert_y1 < hor_y and hor_y < vert_y2 do
      true ->
	steps = calc_steps(vert_x, hor_x1, hor_x2, hor_steps) +
	calc_steps(hor_y, vert_y1, vert_y2, vert_steps)
	[{abs(hor_y) + abs(vert_x), steps}]
      false ->
	[]
    end
  end

  defp calc_steps(cross, lower, upper, steps) do
    case steps < 0 do
      true ->
	upper - cross - steps
      false ->
	steps + cross - lower
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      parse_line(String.split(line, ","), {0, 0}, 0)
    end)
  end

  defp parse_line([move | moves], from, total_steps) do
    <<dir, steps :: binary>> = move
    {steps, ""} = Integer.parse(steps)
    to = move_to(from, dir, steps)
    move = {from, to}
    [{move, total_steps} | parse_line(moves, to, total_steps + steps)]
  end
  defp parse_line([], _, _), do: []

  defp move_to({x, y}, dir, steps) do
    case dir do
      ?U -> {x, y + steps}
      ?D -> {x, y - steps}
      ?L -> {x - steps, y}
      ?R -> {x + steps, y}
    end
  end
end
