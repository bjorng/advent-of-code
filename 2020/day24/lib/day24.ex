defmodule Day24 do
  def part1(input) do
    parse(input)
    |> Enum.reduce(MapSet.new(), &flip_tiles/2)
    |> MapSet.size
  end

  def part2(input) do
    parse(input)
    |> Enum.reduce(MapSet.new(), &flip_tiles/2)
    |> Stream.iterate(&one_day/1)
    |> Stream.drop(100)
    |> Enum.take(1)
    |> hd
    |> Enum.count
  end

  defp one_day(black) do
    new_black = white_tiles(black)
    |> Enum.reduce([], fn location, acc ->
      n = num_adjacent_black_tiles(black, location)
      if (n === 2), do: [location | acc], else: acc
    end)

    black
    |> Enum.reduce(new_black, fn location, acc ->
      n = num_adjacent_black_tiles(black, location)
      if (n === 0 or n > 2), do: acc, else: [location | acc]
    end)
    |> MapSet.new
  end

  defp white_tiles(black_tiles) do
    black_tiles
    |> Enum.flat_map(&adjacent_tiles/1)
    |> Enum.uniq
  end

  defp num_adjacent_black_tiles(black_tiles, location) do
    adjacent_tiles(location)
    |> Enum.count(fn adjacent ->
      MapSet.member?(black_tiles, adjacent)
    end)
  end

  defp adjacent_tiles(location) do
      Enum.map(~w(nw ne w e sw se)a, fn direction ->
        hex_move(direction, location)
      end)
  end

  defp flip_tiles(line, black_tiles) do
    tile = Enum.reduce(line, {0, 0, 0}, &hex_move/2)
    case MapSet.member?(black_tiles, tile) do
      true -> MapSet.delete(black_tiles, tile)
      false -> MapSet.put(black_tiles, tile)
    end
  end

  # https://www.redblobgames.com/grids/hexagons
  defp hex_move(:nw, {x, y, z}), do: {x + 0, y + 1, z - 1}
  defp hex_move(:ne, {x, y, z}), do: {x + 1, y + 0, z - 1}
  defp hex_move(:w,  {x, y, z}), do: {x - 1, y + 1, z + 0}
  defp hex_move(:e,  {x, y, z}), do: {x + 1, y - 1, z + 0}
  defp hex_move(:sw, {x, y, z}), do: {x - 1, y + 0, z + 1}
  defp hex_move(:se, {x, y, z}), do: {x + 0, y - 1, z + 1}

  defp parse(input) do
    Enum.map(input, &parse_line/1)
  end

  defp parse_line(line) do
    case line do
      "e" <> line ->  [:e  | parse_line(line)]
      "se" <> line -> [:se | parse_line(line)]
      "sw" <> line -> [:sw | parse_line(line)]
      "w" <> line ->  [:w  | parse_line(line)]
      "nw" <> line -> [:nw | parse_line(line)]
      "ne" <> line -> [:ne | parse_line(line)]
      "" -> []
    end
  end
end
