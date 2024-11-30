defmodule Day22 do
  def part1(input) do
    parse(input)
    |> lower
    |> safe_bricks
    |> Enum.count
  end

  defp safe_bricks(bricks) do
    safe_bricks(bricks, [], [])
  end

  defp safe_bricks([], _acc, safe), do: safe
  defp safe_bricks([brick | bricks], acc, safe) do
    removed = bricks ++ acc
    case lower_all(removed) do
      ^removed ->
        safe_bricks(bricks, [brick | acc], [brick | safe])
      _ ->
        safe_bricks(bricks, [brick | acc], safe)
    end
  end

  def part2(input) do
    parse(input)
    |> lower
    |> critical_bricks
  end

  defp critical_bricks(bricks) do
    critical_bricks(bricks, [], 0)
  end

  defp critical_bricks([], _acc, n), do: n
  defp critical_bricks([brick | bricks], acc, n) do
    removed = bricks ++ acc
    case lower(removed) do
      ^removed ->
        critical_bricks(bricks, [brick | acc], n)
      new_bricks ->
        n = n + num_lowered(removed, new_bricks)
        critical_bricks(bricks, [brick | acc], n)
    end
  end

  defp num_lowered(a, b), do: num_lowered(a, b, 0)

  defp num_lowered([], [], n), do: n
  defp num_lowered([head1 | tail1], [head2 | tail2], n) do
    if head1 === head2 do
      num_lowered(tail1, tail2, n)
    else
      num_lowered(tail1, tail2, n + 1)
    end
  end

  defp lower(bricks) do
    case lower_all(bricks) do
      ^bricks ->
        bricks
      bricks ->
        lower(bricks)
    end
  end

  defp lower_all(bricks) do
    lower_all(bricks, [])
  end

  defp lower_all([], acc), do: Enum.reverse(acc)
  defp lower_all([{_, _, 1.._} = brick | bricks], acc) do
    lower_all(bricks, [brick | acc])
  end
  defp lower_all([brick | bricks], acc) do
    lowered = lower_brick(brick)
    if all_disjoint?(lowered, bricks) and all_disjoint?(lowered, acc) do
      lower_all([lowered | bricks], acc)
    else
      lower_all(bricks, [brick | acc])
    end
  end

  defp all_disjoint?(brick, bricks) do
    Enum.all?(bricks, &disjoint?(&1, brick))
  end

  defp disjoint?({xr1, yr1, zr1}, {xr2, yr2, zr2}) do
    Range.disjoint?(xr1, xr2) or
    Range.disjoint?(yr1, yr2) or
    Range.disjoint?(zr1, zr2)
  end

  defp lower_brick({xr, yr, zmin..zmax}) do
    {xr, yr, zmin-1..zmax-1}
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, "~")
      |> Enum.map(fn coordinates ->
        String.split(coordinates, ",")
        |> Enum.map(&String.to_integer/1)
      end)
      |> normalize
    end)
    |> Enum.sort_by(fn {x, y, z} -> {z, x, y} end)
  end

  defp normalize(lists) do
    Enum.zip(lists)
    |> Enum.map(fn {a, b} ->
      if a < b do
        a..b
      else
        b..a
      end
    end)
    |> List.to_tuple
  end
end
