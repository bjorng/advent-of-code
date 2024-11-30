# Both parts are solved with brute force. y limits are tailored to my
# input data (with a wide margin). Finishes in less than 3 seconds
# on my computer.

defmodule Day17 do
  def part1(input) do
    {xrange, _yrange} = ranges = parse(input)

    Enum.reduce(1..xrange.last+1, 0, fn x, best ->
      Enum.reduce(1..500, best, fn y, best ->
        case max_height({x, y}, ranges) do
          nil ->
            best
          height ->
            max(best, height)
        end
      end)
    end)
  end

  def part2(input) do
    {xrange, _yrange} = ranges = parse(input)

    Enum.reduce(1..xrange.last+1, 0, fn x, count ->
      Enum.reduce(-500..500, count, fn y, count ->
        case max_height({x, y}, ranges) do
          nil ->
            count
          _height ->
            count + 1
        end
      end)
    end)
  end

  defp max_height(initial, ranges) do
    state = {{0, 0}, 0, initial}
    {final_pos, max_y, _} =
      Stream.iterate(state, &next/1)
      |> Stream.drop_while(&not_done?(&1, ranges))
      |> Enum.take(1)
      |> hd

    case missed?(final_pos, ranges) do
      true -> nil
      false -> max_y
    end
  end

  defp next({{x, y}, max_y, {xv, yv}}) do
    x = x + xv
    y = y + yv
    max_y = max(max_y, y)
    true = xv >= 0
    xv = max(0, xv - 1)
    yv = yv - 1
    {{x, y}, max_y, {xv, yv}}
  end

  defp not_done?({{x, y} = pos, _, _}, {xrange, yrange} = ranges) do
    (x not in xrange or y not in yrange) and not missed?(pos, ranges)
  end

  defp missed?({x, y}, {xrange, yrange}) do
    x > xrange.last or y < yrange.first
  end

  defp parse(input) do
    [x1, x2, y1, y2] =
      Regex.run(~r/x=([-\d]+)[.][.]([-\d]+), y=([-\d]+)[.][.]([-\d]+)/,
        hd(input), [capture: :all_but_first])
        |> Enum.map(&String.to_integer/1)
    {x1..x2, y1..y2}
  end
end
