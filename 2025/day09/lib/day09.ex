defmodule Day09 do
  def part1(input) do
    tiles = parse(input)
    tiles
    |> Enum.flat_map(fn a ->
      Enum.flat_map(tiles, fn b ->
        if a < b do
          [area(a, b)]
        else
          []
        end
      end)
    end)
    |> Enum.sort(:desc)
    |> Enum.take(1)
    |> hd
  end

  def part2(input, debug \\ nil) do
    tiles = parse(input)

    if debug === nil do
      solve(tiles, nil)
    else
      IO.puts ""
      IO.inspect(debug, label: :debug)

      results = [&Function.identity/1, &rot90a/1, &rot90b/1, &rot180/1]
      |> Enum.map(fn tr ->
        if debug === :all do
          transform(tiles, tr)
          |> solve(nil)
        else
          {debug, tiles} = transform(debug ++ tiles, tr)
          |> Enum.split(2)
          debug = Enum.sort(debug)
          solve(tiles, debug)
        end
      end)

      case Enum.uniq(results) do
        [results] ->
          results
        _ ->
          IO.inspect(results)
          IO.puts "\n" <> IO.ANSI.red() <>
            "Different results" <>
            IO.ANSI.reset()
          :different_results
      end
    end
  end

  defp solve(tiles, debug) do
    transposed = tiles
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.reverse

    plain = prepare_tiles(tiles, debug)
    transposed = prepare_tiles(transposed, transpose_region(debug))

    do_solve(plain, transposed)
  end

  defp prepare_tiles(tiles, debug) do
    edges = Enum.chunk_every(tiles, 2, 1, tiles)

    convex = Enum.chunk_every(edges, 2, 1, edges)
    |> Enum.map(fn [[p1, p2], [p2, p3]] ->
      {p2, {cross_z(p1, p2, p3), p1, p3}}
    end)
    |> Map.new

    {tiles, edges, convex, debug}
  end

  defp transpose_region(list) when is_list(list) do
    list
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.sort
  end
  defp transpose_region(region), do: region

  defp do_solve(plain, transposed) do
    {tiles, _, _, debug} = plain

    if length(tiles) < 0 do
      IO.puts ""
      print_grid(tiles)
      {more_tiles, _, _, _} = transposed
      IO.puts ""
      print_grid(more_tiles)
    end

    tiles = if is_list(debug), do: debug, else: tiles

    tiles
    |> Enum.flat_map(fn a ->
      Enum.flat_map(tiles, fn b ->
        if a >= b do
          []
        else
          # Check that the horizontal lines joining the other
          # two corners only pass red and green tiles.
          case solve_one([a, b], plain) do
            [] ->
              []
            [{area, units}] ->
              # Now do the same check for the vertical lines. That is
              # equivalent to checking that the horizontal lines on
              # the tiles rotated 90 degrees.
              region = transpose_region([a, b])
              case solve_one(region, transposed) do
                [{^area, _}] ->
                  [{area, units}]
                _vertical ->
                  []
              end
          end
        end
      end)
    end)
    |> Enum.sort(:desc)
    |> then(fn result ->
      case result do
        [] -> 0
        [{area, _} | _] -> area
      end
    end)
  end

  # Given two diagonal corners, check that the two horizontal
  # lines going to the other two corners of the rectangle
  # only have red and green tiles.
  defp solve_one([a, b], {_tiles, edges, convex, _debug}) do
    {lx, y1} = a
    {rx, y2} = b
    c = {lx, y2}
    d = {rx, y1}

    areas = [{b, c, sign(lx - rx)}, {a, d, sign(rx - lx)}]
    |> Enum.filter(fn {from, to, dir} ->
      if from === to do
        false
      else
        walk(from, to, dir, edges, convex)
      end
    end)

    case areas do
      [_, _] ->
        [{area(a, b), {a, b}}]
      [_] when c === a or d === b ->
        [{area(a, b), {a, b}}]
      _ ->
        []
    end
  end

  defp sign(int) do
    cond do
      int < 0 -> -1
      int > 0 -> 1
      true -> 0
    end
  end

  defp area({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
  end

  defp walk(from, to, dir, edges, convex) do
    where = classify_corner(from, dir, convex)

    {from_x, from_y} = from
    {to_x, _} = to

    # Only keep the relevant vertical edges.
    edges = edges
    |> Enum.filter(fn [{_,y1}, {_,y2}] ->
      y1 !== y2 and from_y in min(y1, y2)..max(y1, y2)
    end)

    case dir do
      -1 ->
        edges
        |> Enum.reject(fn [{x1,_}, {x1,_}] ->
          from_x < x1
        end)
        |> Enum.sort(:desc)
        |> then(fn edges ->
          walk_1(tl(edges), dir, to, convex, where)
        end)
      1 ->
        edges
        |> Enum.reject(fn [{x1,_}, {x1,_}] ->
          x1 < from_x or x1 > to_x
        end)
        |> Enum.sort
        |> then(fn edges ->
          walk_1(tl(edges), dir, to, convex, where)
        end)
    end
  end

  # Classify a corner with respect to the horizontal direction.
  # Returns one of :edge, :inside, or :outside.
  defp classify_corner(from, dir, convex) do
    {from_x, _} = from
    other_corner = case convex do
                     %{^from => {_, {^from_x, _}, other}} -> other
                     %{^from => {_, other, {^from_x, _}}} -> other
                   end

    {diff_x, _} = sub(other_corner, from)
    case sign(diff_x) do
      ^dir ->
        # Walking in the given direction is along the edge to
        # the other corner.
        :edge
      _ ->
        # We will not walk along the edge, but we will enter move to
        # to the inside or outside.
        case is_convex(convex, from) do
          :concave -> :inside
          :convex -> :outside
        end
    end
  end

  # Walk from a corner point horizontally in either direction.
  # Returns `true` if the destination point `to` can be reached
  # by only passing red and green tiles.
  defp walk_1(_, _dir, _to, _convex, :outside) do
    false
  end
  defp walk_1([], _dir, _to, _convex, _) do
    true
  end
  defp walk_1([[a, b] | edges], dir, to, convex, where) do
    {to_x, to_y} = to
    {ab_x, a_y} = a
    {_, b_y} = b
    cond do
      dir === -1 and ab_x <= to_x ->
        [{x, y1}, {x, y2}] = [a, b]
        true = to_y in y1..y2//sign(y2-y1) # assertion
        where === :edge or where === :inside
      dir === 1 and to_x <= ab_x ->
        [{x, y1}, {x, y2}] = [a, b]
        true = to_y in y1..y2//sign(y2-y1) # assertion
        where === :edge or where === :inside
      a_y === to_y and corner?(convex, a) ->
        where = pass_corner(where, is_convex(convex, a))
        walk_1(edges, dir, to, convex, where)
      b_y === to_y and corner?(convex, b) ->
        where = pass_corner(where, is_convex(convex, b))
        walk_1(edges, dir, to, convex, where)
      true ->
        [{x, y1}, {x, y2}] = [a, b]
        true = to_y in y1..y2//sign(y2-y1) # assertion
        where = pass_edge(where)
        walk_1(edges, dir, to, convex, where)
    end
  end

  defp corner?(convex, point) do
    Map.get(convex, point) !== nil
  end

  defp is_convex(convex, corner) do
    {area, _, _} = Map.get(convex, corner)
    if area > 0, do: :convex, else: :concave
  end

  defp pass_corner(:edge, :convex), do: :outside
  defp pass_corner(:edge, :concave), do: :inside
  defp pass_corner(:inside, :concave), do: :edge

  defp pass_edge(:inside), do: :outside
  defp pass_edge(:outside), do: :inside

  defp cross_z({x1, y1}, {x2, y2}, {x3, y3}) do
    (x2 - x1) * (y3 - y2) - (y2 - y1) * (x3 - x2)
  end

  defp sub({x1, y1}, {x2, y2}) do
    {x1 - x2, y1 - y2}
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
  end

  # Helpers for debugging follow.

  defp transform(tiles, f) do
    tiles = Enum.map(tiles, f)
    {min_x, _} = Enum.min_by(tiles, &elem(&1, 0))
    {_, min_y} = Enum.min_by(tiles, &elem(&1, 1))
    Enum.map(tiles, fn {x, y} -> {x - min_x, y - min_y} end)
  end

  defp rot90a({a, b}), do: {b, -a}
  defp rot90b({a, b}), do: {-b, a}
  defp rot180({a, b}), do: {-a, -b}

  def print_grid(tiles) do
    grid = tiles
    |> Enum.chunk_every(2, 1, tiles)
    |> Enum.flat_map(fn [a, b] ->
      case {a, b} do
        {{x1, y}, {x2, y}} ->
          Enum.map(x1..x2//sign(x2 - x1), &{{&1, y}, ?X})
        {{x, y1}, {x, y2}} ->
          Enum.map(y1..y2//sign(y2 - y1), &{{x, &1}, ?X})
        end ++ [{a, ?\#}, {b, ?\#}]
    end)
    |> Map.new

    {{x2, _}, _} = Enum.max_by(grid, fn {{x, _}, _} -> x end)
    {{_, y2}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)

    Enum.each(0..y2+2, fn y ->
      Enum.map(0..x2+2, fn x ->
        Map.get(grid, {x, y}, ?.)
      end)
      |> IO.puts
    end)
  end
end
