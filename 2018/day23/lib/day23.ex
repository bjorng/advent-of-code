defmodule Day23 do
  def part1(lines) do
    bots = lines
    |> Enum.map(&parse_line/1)
    {strongest_pos, radius} = Enum.max_by(bots, fn {_, r} -> r end)
    bots
    |> Stream.filter(fn {pos, _} ->
      manhattan_distance(strongest_pos, pos) <= radius
    end)
    |> Enum.count
  end

  def part2(lines) do
    bots = lines
    |> Enum.map(&parse_line/1)
    bounding_box = bounding_box(bots)
    scale_while(bots, bounding_box)
  end

  def num_overlapping(lines, coordinate) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.filter(fn bot -> in_range?(bot, coordinate) end)
    |> Enum.count
  end

  defp scale_while(bots, bounding_box) do
    {scaled_bots, scaled_bounding_box, scaling} =
      scale_bots(bots, bounding_box)

    #IO.inspect bounding_box, label: 'bounding box'
    #IO.inspect scaled_bounding_box, label: 'scaled bounding box'

    {_, most_freq_pos} = result = scaled_bots
    |> most_frequent_coord(scaled_bounding_box)

    case scaling do
      nil ->
        result
      _ ->
        bounding_box = reduce_bounding_box(scaling, most_freq_pos)
        scale_while(bots, bounding_box)
    end
  end

  defp scale_bots(bots, bounding_box) do
    min_coord = min_coords(bots)
    case scale_factor(bounding_box) do
      nil ->
        #IO.inspect 'no scaling'
        #IO.inspect bounding_box, label: 'bounding box'
        {bots, bounding_box, nil};
      scale ->
        #IO.inspect scale, label: 'scale factor'
        bots =
          Enum.map(bots, fn {coord, r} ->
            {scale(sub(coord, min_coord), scale), scale(r, scale)}
          end)
        {min, max} = bounding_box
        bounding_box = {scale(sub(min, min_coord), scale),
                        scale(sub(max, min_coord), scale)}
        {bots, bounding_box, {min_coord, scale}}
    end
  end

  defp scale_factor({min, max}) do
    extents = sub(max, min)
    axis = shortest_axis(extents)
    extent = elem(extents, axis)
    n = 4
    if extent > n do
      div(extent, n)
    else
      nil
    end
  end

  # Reduce the bounding area to be around the area with the
  # highest number of overlapping coordinates. Add some considerable
  # margin.

  defp reduce_bounding_box({{x0, y0, z0}, scale}, {x, y, z}) do
    x_min = (x - 1) * scale + x0
    y_min = (y - 1) * scale + y0
    z_min = (z - 1) * scale + z0
    min = {x_min, y_min, z_min}
    max = {x_min + 3 * scale - 1,
           y_min + 3 * scale - 1,
           z_min + 3 * scale - 1}
    {min, max}
  end

  defp min_coords(bots) do
    {acc, _}  = hd(bots)
    Enum.reduce(bots, acc, fn {{x, y, z}, _}, {min_x, min_y, min_z} ->
      {min(x, min_x), min(y, min_y), min(z, min_z)}
    end)
  end

  defp sub({x, y, z}, {x0, y0, z0}) do
    {x - x0, y - y0, z - z0}
  end

  defp scale({x, y, z}, scale) do
    {div(x, scale), div(y, scale), div(z, scale)}
  end

  defp scale(integer, scale) do
    # Round up the radius.
    div(integer + scale - 1, scale)
  end

  defp most_frequent_coord(bots, bounding_box) do
    bots
    |> count_coordinates(bounding_box, [])
    |> Enum.min_by(fn {pos, count} ->
      {-count, manhattan_distance(pos, {0, 0, 0})}
    end)
    |> (fn {pos, _} ->
      {manhattan_distance(pos, {0, 0, 0}), pos}
    end).()
  end

  defp count_coordinates(bots, bb, acc) do
    {{min_x, min_y, min_z}, {max_x, max_y, max_z}} = bb
    Enum.reduce(min_x..max_x, acc, fn x, acc ->
      Enum.reduce(min_y..max_y, acc, fn y, acc ->
        Enum.reduce(min_z..max_z, acc, fn z, acc ->
          pos = {x, y, z}
          num_coords = bots
          |> Stream.filter(fn bot -> in_range?(bot, pos) end)
          |> Enum.count
          [{pos, num_coords} | acc]
        end)
      end)
    end)
  end

  defp in_range?({center, radius}, coordinate) do
    manhattan_distance(center, coordinate) <= radius
  end

  defp shortest_axis(extents) do
    Tuple.to_list(extents)
    |> Enum.with_index
    |> Enum.min
    |> (fn {_, axis} -> axis end).()
  end

  defp bounding_box(bots) do
    {pos, _r} = hd(bots)
    acc = {pos, pos}
    Enum.reduce(bots, acc, fn {{x, y, z}, _r}, {min, max} ->
      {min_x, min_y, min_z} = min
      min = {min(x, min_x), min(y, min_y), min(z, min_z)}
      {max_x, max_y, max_z} = max
      max = {max(x, max_x), max(y, max_y), max(z, max_z)}
      {min, max}
    end)
  end

  defp manhattan_distance({x0, y0, z0}, {x, y, z}) do
    abs(x0 - x) + abs(y0 - y) + abs(z0 - z)
  end

  defp parse_line(line) do
    re = ~r/^pos=<(-?\d+),(-?\d+),(-?\d+)>,\s*r=(\d+)$/
    numbers = Regex.run re, line, capture: :all_but_first
    [x, y, z, r] = Enum.map(numbers, &String.to_integer/1)
    {{x, y, z}, r}
  end
end
