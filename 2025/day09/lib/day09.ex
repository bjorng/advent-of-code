defmodule Day09 do
  def part1(input) do
    tiles = parse(input)
    tiles
    |> Enum.flat_map(fn a ->
      Enum.flat_map(tiles, fn b ->
        if a < b, do: [area(a, b)], else: []
      end)
    end)
    |> Enum.sort(:desc)
    |> Enum.take(1)
    |> hd
  end

  def part2(input) do
    tiles = parse(input)

    transposed = tiles
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.reverse

    plain = prepare_tiles(tiles)
    transposed = prepare_tiles(transposed)

    {tiles, _, _} = plain

    tiles = Enum.sort(tiles)
    Enum.reduce(tiles, 0, fn a, max_area ->
      Enum.reduce(tiles, max_area, fn b, max_area ->
        if a >= b do
          max_area
        else
          area = area(a, b)
          if area <= max_area do
            max_area
          else
            region1 = [a, b]
            region2 = Enum.map(region1, fn {x, y} -> {y, x} end)
            if solve_one(region1, plain) and solve_one(region2, transposed) do
              area
            else
              max_area
            end
          end
        end
      end)
    end)
  end

  defp prepare_tiles(tiles) do
    edges = Enum.chunk_every(tiles, 2, 1, tiles)
    |> Enum.map(&List.to_tuple/1)

    convex = Enum.chunk_every(edges, 2, 1, edges)
    |> Enum.map(fn [{p1, p2}, {p2, p3}] ->
      convex? = if cross_z(p1, p2, p3) > 0, do: :convex, else: :concave
      {p2, {convex?, p1, p3}}
    end)
    |> Map.new

    {tiles, edges, convex}
  end

  # Given two diagonal corners, check that the two horizontal
  # lines going to the other two corners of the rectangle
  # only have red and green tiles.
  defp solve_one([a, b], {_tiles, edges, convex}) do
    {lx, y1} = a
    {rx, y2} = b
    c = {lx, y2}
    d = {rx, y1}

    cond do
      c === a or d === b ->
        [{b, c, sign(lx - rx)}]
      true ->
        [{b, c, sign(lx - rx)}, {a, d, sign(rx - lx)}]
    end
    |> Enum.all?(fn {from, to, dir} ->
      if from === to do
        false
      else
        walk(from, to, dir, edges, convex)
      end
    end)
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
    case classify_corner(from, dir, convex) do
      :outside ->
        false
      where ->
        {from_x, from_y} = from
        {to_x, _} = to

        # Only keep the relevant vertical edges.
        edges = edges
        |> Enum.filter(fn {{_,y1}, {_,y2}} ->
          y1 !== y2 and from_y in min(y1, y2)..max(y1, y2)
        end)

        case dir do
          -1 ->
            edges
            |> Enum.reject(fn {{x1,_}, {x1,_}} ->
              from_x < x1 or to_x > x1
            end)
            |> Enum.sort(:desc)
            |> then(fn edges ->
              walk_1(tl(edges), dir, to, convex, where)
            end)
          1 ->
            edges
            |> Enum.reject(fn {{x1,_}, {x1,_}} ->
              x1 < from_x or x1 > to_x
            end)
            |> Enum.sort
            |> then(fn edges ->
              walk_1(tl(edges), dir, to, convex, where)
            end)
        end
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
  defp walk_1([{a, b} | edges], dir, to, convex, where) do
    {to_x, to_y} = to
    {ab_x, a_y} = a
    {_, b_y} = b
    cond do
      dir === -1 and ab_x <= to_x ->
        # Destination is on the edge or at the corner.
        where === :edge or where === :inside
      dir === 1 and to_x <= ab_x ->
        # Destination is on the edge or at the corner.
        where === :edge or where === :inside
      a_y === to_y and corner?(convex, a) ->
        # Destination is beyond this corner.
        where = pass_corner(where, is_convex(convex, a))
        walk_1(edges, dir, to, convex, where)
      b_y === to_y and corner?(convex, b) ->
        # Destination is beyond this corner.
        where = pass_corner(where, is_convex(convex, b))
        walk_1(edges, dir, to, convex, where)
      true ->
        # Destination is beyond this edge.
        false
    end
  end

  defp corner?(convex, point) do
    Map.has_key?(convex, point)
  end

  defp is_convex(convex, corner) do
    {convex?, _, _} = Map.get(convex, corner)
    convex?
  end

  defp pass_corner(:edge, :convex), do: :outside
  defp pass_corner(:edge, :concave), do: :inside
  defp pass_corner(:inside, :concave), do: :edge

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
end
