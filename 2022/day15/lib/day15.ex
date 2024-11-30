defmodule Day15 do
  def part1(input, row \\ 2_000_000) do
    parse(input)
    |> Enum.flat_map(fn {sensor, {xb, yb} = beacon} ->
      distance = manhattan_distance(sensor, beacon)
      case no_beacons_range(sensor, distance, row) do
        [] ->
          []
        [range] when yb === row ->
          case sub_range(range, {xb, xb}) do
            [] ->
              []
            [range] ->
              [{sensor, range}]
          end
        [range] ->
          [{sensor, range}]
      end
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sort
    |> merge_ranges
    |> Enum.map(fn {first, last} -> last - first + 1 end)
    |> Enum.sum
  end

  defp no_beacons_range({x, y}, distance, row) do
    case (distance - abs(y - row)) do
      distance when distance < 0 ->
        []
      distance ->
        [{x - distance, x + distance}]
    end
  end

  defp merge_ranges([{first1, last1}, {first2, last2} | ranges]) when first2 <= last1 do
    merge_ranges([{first1, max(last1, last2)} | ranges])
  end
  defp merge_ranges([range | ranges]) do
    [range | merge_ranges(ranges)]
  end
  defp merge_ranges([]), do: []

  def part2(input, max_coord \\ 4_000_000) do
    sensors = parse(input)
    |> Enum.map(fn {sensor, beacon} ->
      {sensor, manhattan_distance(sensor, beacon)}
    end)
    |> Enum.sort(fn {{_, y1}, distance1}, {{_, y2}, distance2} ->
      # Sorting reduces running time from 2.1 seconds to 1.5 seconds
      # on my computer.
      y1 - distance1 <= y2 - distance2
    end)

    possible_ranges = [{0,max_coord}]
    Enum.find_value(0..max_coord,
      fn row ->
        find_beacon(sensors, row, possible_ranges)
      end)
  end

  defp find_beacon(sensors, row, possible_ranges) do
    possible_ranges =
      Enum.reduce_while(sensors, possible_ranges,
        fn {{x, y}, distance}, possible_ranges ->
          case (distance - abs(y - row)) do
            distance when distance < 0 ->
              {:cont, possible_ranges}
            distance ->
              impossible_range = {x - distance, x + distance}
              case sub_ranges(possible_ranges, impossible_range) do
                [] ->
                  {:halt, []}
                possible_ranges ->
                  {:cont, possible_ranges}
              end
          end
        end)
    case possible_ranges do
      [{x, x}] ->
        4_000_000 * x + row
      _ ->
        nil
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp sub_ranges(ranges, range) do
    Enum.flat_map(ranges, &sub_range(&1, range))
  end

  defp sub_range({first1, last1}, {first2, last2}) when first1 <= first2 and first2 <= last1 do
    make_range(first1, first2 - 1) ++ make_range(last2 + 1, last1)
  end
  defp sub_range({first1, last1}, {first2, last2}) when first2 < first1 and first1 <= last2 do
    make_range(last2 + 1, last1)
  end
  defp sub_range({first1, last1}, {first2, last2}) when first1 <= first2 and last2 <= last1 do
    make_range(first1, first2 - 1) ++ make_range(last2 + 1, last1)
  end
  defp sub_range({first1, _} = range, {_, last2}) when last2 < first1 do
    [range]
  end
  defp sub_range({_, last1}=range, {first2, _}) when last1 < first2 do
    [range]
  end

  defp make_range(first, last) when first <= last, do: [{first, last}]
  defp make_range(_, _), do: []

  defp parse(input) do
    Enum.map(input, &parse_line/1)
  end

  defp parse_line("Sensor at " <> rest) do
    {sensor, rest} = parse_position(rest)
    ": closest beacon is at " <> rest = rest
    {beacon, ""} = parse_position(rest)
    {sensor, beacon}
  end

  defp parse_position("x=" <> rest) do
    {x, ", y=" <> rest} = Integer.parse(rest)
    {y, rest} = Integer.parse(rest)
    {{x, y}, rest}
  end
end

