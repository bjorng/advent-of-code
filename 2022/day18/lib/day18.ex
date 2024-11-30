defmodule Day18 do
  def part1(input) do
    positions = parse(input)
    |> MapSet.new
    Enum.reduce(positions, 0, fn position, area ->
      surfaces = neighbors(position)
      |> Enum.count(&(not MapSet.member?(positions, &1)))
      area + surfaces
    end)
  end

  def part2(input) do
    droplets = parse(input) |> MapSet.new
    ranges = ranges(droplets)
    smallest = Enum.map(0..2, &(elem(ranges, &1).first)) |> List.to_tuple
    worklist = [smallest]
    seen = MapSet.new([smallest])
    area = 0
    flood_fill(worklist, ranges, seen, droplets, area)
  end

  defp flood_fill([], _ranges, _seen, _droplets, area), do: area
  defp flood_fill([cube | worklist], ranges, seen, droplets, area) do
    {neighbors, {seen, area}} = cube
    |> neighbors
    |> Enum.filter(fn position ->
      Enum.all?(0..2, fn axis ->
        elem(position, axis) in elem(ranges, axis)
      end)
    end)
    |> Enum.flat_map_reduce({seen, area}, fn position, {seen, area} ->
      case MapSet.member?(seen, position) do
        true ->
          {[], {seen, area}}
        false ->
          case MapSet.member?(droplets, position) do
            true ->
              {[], {seen, area + 1}}
            false ->
              seen = MapSet.put(seen, position)
              {[position], {seen, area}}
          end
      end
    end)
    flood_fill(neighbors ++ worklist, ranges, seen, droplets, area)
  end

  defp ranges(positions) do
    Enum.map(0..2, fn axis ->
      {min, max} = Enum.min_max_by(positions, &elem(&1, axis))
      (elem(min, axis) - 1) .. (elem(max, axis) + 1)
    end)
    |> List.to_tuple
  end

  defp neighbors(position) do
    Enum.flat_map(0..2, fn index ->
      axis = elem(position, index)
      [put_elem(position, index, axis - 1),
       put_elem(position, index, axis + 1)]
    end)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
  end
end
