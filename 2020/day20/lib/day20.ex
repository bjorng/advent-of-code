defmodule Day20 do
  def part1(input), do: Day20Part1.part1(input)
  def part2(input), do: Day20Part2.part2(input)
end

defmodule Day20Part2 do
  import Bitwise

  def part2(input) do
    compose_image(input)
    |> find_sea_monster
  end

  #
  # Here follows the code for placing the tiles and
  # combining them to an image.
  #

  defp compose_image(input) do
    all = parse(input)
    |> Enum.map(fn {id, grid_lines} ->
      poses = all_poses(grid_lines)
      {id, {nil, Enum.map(poses, &borders/1), poses}}
    end)

    # Choose an arbitrary tile and place it at the origin.
    [{id, {_, [borders | _], [grid_lines | _]}} | rest] = all
    origin = {0, 0}
    all = Map.new([{id, {origin, id, grid_lines}} | rest])
    all_ids = Map.keys(all)

    # Place all other tiles around the already placed tiles.
    image = update_todo(borders, origin)
    |> Enum.reduce(:queue.new(), &:queue.in/2)
    |> place_tiles(all, all_ids)
    |> Map.values
    |> Enum.sort_by(fn {{x, y}, _, _} -> {y, x} end)
    |> Enum.chunk_by(fn {{_x, y}, _, _} -> y end)
    |> Enum.flat_map(&merge_tile/1)
    |> normalize_image
    image
  end

  defp all_poses(image) do
    rot1 = rot90(image)
    rot2 = rot90(rot1)
    rot3 = rot90(rot2)
    flip0 = Enum.reverse(image)
    flip1 = rot90(flip0)
    flip2 = rot90(flip1)
    flip3 = rot90(flip2)
    [image, rot1, rot2, rot3,
     flip0, flip1, flip2, flip3]
  end

  defp normalize_image(image) do
    width = div(round(:math.sqrt(length(image) * 8)), 8)
    normalize_image(image, width)
  end

  defp normalize_image([], _width), do: []
  defp normalize_image(image, width) do
    {numbers, image} = Enum.split(image, width)
    n = Enum.reduce(numbers, 0, fn n, acc ->
      (acc <<< 8) ||| n
    end)
    [n | normalize_image(image, width)]
  end

  defp merge_tile(grid_line) do
    Enum.map(grid_line, fn {_, _, line} ->
      dimension = length(line) - 2
      mask = ((1 <<< dimension) - 1) <<< 1
      Enum.take(tl(line), dimension)
      |> Enum.map(fn line ->
        (line &&& mask) >>> 1
      end)
    end)
    |> transpose
  end

  defp transpose(lists) do
    transpose(lists, [], [])
  end

  defp transpose([[head | tail] | lists], lists_acc, acc) do
    transpose(lists, [tail | lists_acc], [head | acc])
  end
  defp transpose([], lists_acc, acc) do
    transpose(Enum.reverse(lists_acc), [], acc)
  end
  defp transpose([[] | _], _lists_acc, acc) do
    Enum.reverse(acc)
  end

  defp place_tiles(todo, all, all_ids) do
    case :queue.out(todo) do
      {:empty, _} ->
        all
      {{:value, {border, dir, position}}, todo} ->
        case place_tile(border, dir, position, all, all_ids) do
          {all, more} ->
            todo = Enum.reduce(more, todo, &:queue.in/2)
            place_tiles(todo, all, all_ids)
          nil ->
            place_tiles(todo, all, all_ids)
        end
    end
  end

  defp place_tile(border, dir, position, all, all_ids) do
    res = Enum.find_value(all_ids, fn id ->
      {position, borders, pixels} = Map.get(all, id)
      if is_nil(position) do
        find_tile(id, border, dir, borders, pixels)
      end
    end)

    case res do
      nil ->
        nil
      {id, borders, grid_lines} ->
        all = Map.put(all, id, {position, id, grid_lines})
        more = update_todo(borders, position)
        {all, more}
    end
  end

  defp update_todo(borders, position) do
    Enum.with_index(borders)
    |> Enum.map(fn {border, dir} ->
      {border, turn_dir(dir), add_dir(position, dir)}
    end)
  end

  defp find_tile(_id, _border, _dir, [], []), do: nil
  defp find_tile(id, border, dir, [borders | bs], [pixels | ps]) do
    case Enum.at(borders, dir) do
      ^border -> {id, borders, pixels}
      _ -> find_tile(id, border, dir, bs, ps)
    end
  end

  defp borders(grid_lines) do
    [hd(grid_lines),
     extract_column(grid_lines, 1, false),
     List.last(grid_lines),
     extract_column(grid_lines, 512, false)]
  end

  def rot90(grid_lines) do
    Enum.reduce(0..length(grid_lines) - 1, [], fn column, acc ->
      [extract_column(grid_lines, 1 <<< column, true) | acc]
    end)
  end

  def extract_column(grid_lines, mask, reverse) do
    grid_lines = case reverse do
                   true -> Enum.reverse(grid_lines)
                   false -> grid_lines
                 end
    Enum.reduce(grid_lines, 0, fn int, acc ->
      (acc <<< 1) ||| extract_bit(int, mask)
    end)
  end

  defp extract_bit(int, mask) do
    case int &&& mask do
      0 -> 0
      _ -> 1
    end
  end

  defp turn_dir(dir) do
    (dir + 2) &&& 3
  end

  defp add_dir({x, y}, dir) do
    case dir do
      0 -> {x, y - 1}
      1 -> {x + 1, y}
      2 -> {x, y + 1}
      3 -> {x - 1, y}
    end
  end

  #
  # Finding the sea monster.
  #

  defp find_sea_monster(image) do
    pattern = sea_monster()
    |> parse_grid_lines

    # There could be overlapping monsters, so we will
    # be careful to find all matches before we remove
    # the monsters.
    image
    |> all_poses
    |> Enum.find_value(fn image ->
      case find_pattern(image, pattern) do
        [] ->
          nil
        found ->
          image
          |> remove_monsters(found)
          |> count_ones
      end
    end)
  end

  defp find_pattern(image, pattern) do
    pat_height = length(pattern)
    width = length(image)
    find_pattern(image, width, pattern, pat_height, 0, [])
  end

  defp find_pattern(image, width, pattern, pat_height, shift, found) do
    shifted = Enum.map(pattern, fn pat -> pat <<< shift end)
    found = find_pattern(image, shifted, pat_height, found)
    shift = shift + 1
    if shift >= width - 18 do
      found
    else
      find_pattern(image, width, pattern, pat_height, shift, found)
    end
  end

  defp find_pattern(image, pattern, pat_height, found) do
    case Enum.take(image, pat_height) do
      [] ->
        found
      lines ->
        case matching_pattern?(lines, pattern) do
          true ->
            found = [{length(image), pattern} | found]
            find_pattern(tl(image), pattern, pat_height, found)
          false ->
            find_pattern(tl(image), pattern, pat_height, found)
        end
    end
  end

  defp matching_pattern?([], []), do: true
  defp matching_pattern?([], [_|_]), do: false
  defp matching_pattern?([line | lines], [pat | ps]) do
    (line &&& pat) === pat and matching_pattern?(lines, ps)
  end

  defp remove_monsters(image, found) do
    found = Enum.sort_by(found, &-elem(&1, 0))
    remove_monsters(image, found, length(image))
  end

  defp remove_monsters(image, [{n, pattern} | found], n) do
    {lines, image} = Enum.split(image, length(pattern))
    lines = Enum.zip(lines, pattern)
    |> Enum.map(fn {line, pat} ->
      line &&& bnot(pat)
    end)
    remove_monsters(lines ++ image, found, n)
  end
  defp remove_monsters([line | lines], found, n) do
    [line | remove_monsters(lines, found, n - 1)]
  end
  defp remove_monsters([], _, _), do: []

  defp count_ones(image) do
    Enum.reduce(image, 0, fn n, acc ->
      count_ones(n, acc)
    end)
  end

  defp count_ones(0, count), do: count
  defp count_ones(n, count) do
    if (n &&& 1) === 1 do
      count_ones(n >>> 1, count + 1)
    else
      count_ones(n >>> 1, count)
    end
  end


  defp sea_monster() do
    """
                      #.
    #    ##    ##    ###
     #  #  #  #  #  #...
    """
    |> String.split("\n", trim: true)
  end

  #
  # Parsing.
  #

  defp parse(lines) do
    Enum.chunk_by(lines, fn line ->
      match?("Tile" <> _, line)
    end)
    |> parse_grid
  end

  defp parse_grid([]), do: []
  defp parse_grid([["Tile " <> num], grid_lines | lines]) do
    {id, ":"} = Integer.parse(num)
    grid = parse_grid_lines(grid_lines)
    [{id, grid} | parse_grid(lines)]
  end

  defp parse_grid_lines(lines) do
    Enum.map(lines, &parse_grid_line/1)
  end

  defp parse_grid_line(line) do
    line
    |> String.to_charlist
    |> Enum.reduce(0, fn char, acc ->
      (acc <<< 1) |||
        case char do
          ?\s -> 0
          ?\. -> 0
          ?\# -> 1
        end
    end)
  end
end

#
# Part 1. Basically as originally written
#

defmodule Day20Part1 do
  import Bitwise

  def part1(input) do
    parse(input)
    |> matching_edges
    |> find_corners
    |> Enum.reduce(1, &*/2)
  end

  defp find_corners(matching) do
    matching
    |> Enum.map(fn chunk ->
      Enum.chunk_by(chunk, &{elem(&1, 1)})
    end)
    |> Enum.reduce([], fn chunks, acc ->
      case chunks do
        [[el|_], _] -> [elem(el, 0) | acc]
        _ -> acc
      end
    end)
  end

  defp matching_edges(grids) do
    grids
    |> Enum.flat_map(&signatures/1)
    |> Enum.sort
    |> Enum.chunk_by(&elem(&1, 0))
    |> Enum.reduce([], fn list, acc ->
      case list do
        [_] ->
          acc
        [{sign, {id1, _, _} = a}, {_, {id2, _, _} = b}] ->
          [{id1, id2, {sign, a, b}}, {id2, id1, {sign, b, a}} | acc]
      end
    end)
    |> Enum.sort
    |> Enum.chunk_by(&elem(&1, 0))
  end

  defp signatures({id, grid_lines}) do
    signatures =
      [hd(grid_lines),
       extract_column(grid_lines, 1, false),
       List.last(grid_lines),
       extract_column(grid_lines, 512, true)]

    flipped = Enum.map(signatures, fn int ->
      flip_bits(int)
    end)

    signatures ++ flipped
    |> Enum.with_index
    |> Enum.map(fn {sign, index} ->
      {sign, {id, index, grid_lines}}
    end)
  end

  defp extract_column(grid_lines, mask, reverse) do
    grid_lines = case reverse do
                   true -> Enum.reverse(grid_lines)
                   false -> grid_lines
                 end
    Enum.reduce(grid_lines, 0, fn int, acc ->
      (acc <<< 1) ||| extract_bit(int, mask)
    end)
  end

  defp extract_bit(int, mask) do
    case int &&& mask do
      0 -> 0
      _ -> 1
    end
  end

  defp flip_bits(int) do
    Enum.reduce(0..9, 0, fn shift, acc ->
      (acc <<< 1) ||| ((int >>> shift) &&& 1)
    end)
  end

  defp parse(lines) do
    Enum.chunk_by(lines, fn line ->
      match?("Tile" <> _, line)
    end)
    |> parse_grid
  end

  defp parse_grid([]), do: []
  defp parse_grid([["Tile " <> num], grid_lines | lines]) do
    {id, ":"} = Integer.parse(num)
    grid = Enum.map(grid_lines, &parse_grid_line/1)
    [{id, grid} | parse_grid(lines)]
  end

  defp parse_grid_line(line) do
    line
    |> String.to_charlist
    |> Enum.reduce(0, fn char, acc ->
      (acc <<< 1) |||
        case char do
          ?\. -> 0
          ?\# -> 1
        end
    end)
  end
end
