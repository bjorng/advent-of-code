defmodule Day05 do
  def part1(input) do
    {seeds, maps} = parse(input)
    Enum.map(seeds, &map_seed(&1, maps))
    |> Enum.min
  end

  defp map_seed(seed, maps) do
    Enum.reduce(maps, seed,
      fn map, acc ->
        find_in_map(map, acc)
      end)
  end

  defp find_in_map([{dest_range, src_range} | ranges], item) do
    if item in src_range do
      dest_range.first + item - src_range.first
    else
      find_in_map(ranges, item)
    end
  end
  defp find_in_map([], item), do: item

  def part2(input) do
    {seed_pairs, maps} = parse(input)
    seed_ranges(seed_pairs)
    |> map_ranges(maps)
    |> Enum.min
    |> Map.fetch!(:first)
  end

  defp seed_ranges([first, n | rest]) do
    [first .. first + n - 1 | seed_ranges(rest)]
  end
  defp seed_ranges([]), do: []

  defp map_ranges(ranges, maps) do
    Enum.reduce(maps, ranges,
      fn maps, ranges ->
        map_ranges(ranges, maps, _mapped = [])
      end)
  end

  defp map_ranges(ranges, [map | maps], mapped) do
    {mapped, unmapped} = map_one_map(ranges, map, mapped, [])
    map_ranges(unmapped, maps, mapped)
  end
  defp map_ranges(unmapped, [], mapped) do
    unmapped ++ mapped
  end

  defp map_one_map([range | ranges], map, mapped, unmapped) do
    {more_mapped, more_unmapped} = map_and_split(range, map)
    unmapped = more_unmapped ++ unmapped
    mapped = more_mapped ++ mapped
    map_one_map(ranges, map, mapped, unmapped)
  end
  defp map_one_map([], _map, mapped, unmapped) do
    {mapped, unmapped}
  end

  defp map_and_split(range, {dest_range, src_range}) do
    case Range.disjoint?(range, src_range) do
      true ->
        {[], [range]}
      false ->
        if range.first <= src_range.first do
          unmapped1 = make_range(range.first .. src_range.first - 1 // 1)
          unmapped2 = make_range(src_range.last + 1 .. range.last // 1)
          unmapped = unmapped1 ++ unmapped2
          first_offset = 0
          last_offset = min(range.last, src_range.last) - src_range.first
          mapped = dest_range.first + first_offset .. dest_range.first + last_offset // 1
          {[mapped], unmapped}
        else
          unmapped = make_range(min(range.last, src_range.last) + 1  .. range.last // 1)
          first_offset = range.first - src_range.first
          last_offset = min(range.last, src_range.last) - src_range.first
          mapped = dest_range.first + first_offset .. dest_range.first + last_offset // 1
          {[mapped], unmapped}
        end
    end
  end

  defp make_range(range) do
    case Range.size(range) do
      0 -> []
      _ -> [range]
    end
  end

  defp parse(input) do
    [seeds | rest] = String.split(input, "\n\n", trim: true)
    ["seeds:" | seeds] = String.split(seeds, " ")
    seeds = Enum.map(seeds, &String.to_integer/1)
    maps = rest
    |> Enum.map(fn line ->
      [_label | ranges] = String.split(line, "\n", trim: true)
      ranges
      |> Enum.map(fn ranges_line ->
        String.split(ranges_line, " ")
        |> Enum.map(&String.to_integer/1)
        |> parse_range
      end)
    end)
    {seeds, maps}
  end

  defp parse_range([dest_range, src_range, num_items]) do
    {dest_range .. dest_range + num_items - 1,
     src_range .. src_range + num_items - 1}
  end
end
