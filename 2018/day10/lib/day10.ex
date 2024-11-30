defmodule Day10 do

  def part1(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> loop(0)
  end

  defp loop points, seconds do
    points
    |> Enum.map(fn {point, _} -> point end)
    |> show(seconds)
    points = Enum.map(points, &move_point/1)
    loop points, seconds + 1
  end

  defp move_point({{x, y}, {dx, dy} = velocity}), do: {{x + dx, y + dy}, velocity}

  defp show(points, seconds) do
    min_coords = min_coords(points)
    points  = points
    |> Enum.map(fn point -> scale(point, min_coords) end)

    {max_x, _} = Enum.max_by(points, fn {x, _} -> x end)
    {_, max_y} = Enum.max_by(points, fn {_, y} -> y end)
    if max_x < 100 and max_y < 100 do
      :io.format("~p seconds\n", [seconds])
      do_show(max_x, max_y, points)
    end
  end

  defp do_show(max_x, max_y, points) do
    point_set = MapSet.new(points)
    output =
    for y <- 0..max_y,
      x <- 0..max_x+1,
	do: get_point(x, y, max_x+1, point_set)
    IO.puts output
    receive do
    after 500 ->
	nil
    end
  end

  defp get_point(nl, _y, nl, _point_set), do: ?\n

  defp get_point(x, y, _nl, point_set) do
    case {x, y} in point_set do
      true -> ?#
      false -> ?.
    end
  end

  defp scale({x, y}, {min_x, min_y}) do
    {x - min_x, y - min_y}
  end

  def part2(lines) do
    lines
  end

  def min_coords coords do
    Enum.reduce(coords,
      fn {x, y}, {min_x, min_y} ->
	{min(x, min_x), min(y, min_y)}
      end)
  end

  @doc """
  Parse a line.

  ## Examples

      iex> Day10.parse_line("position=< 9,  1> velocity=< 0,  2>")
      {{9,1},{0,2}}

  """
  def parse_line line do
    re = ~r/^position=<\s*([-]?\d+),\s*([-]?\d+)> velocity=<\s*([-]?\d+),\s*([-]?\d+)>/;
    str = Regex.run(re, line, [capture: :all_but_first])
    [x, y, dx, dy] =
    for s <- str, do: String.to_integer(s)
    {{x, y}, {dx, dy}}
  end

end
