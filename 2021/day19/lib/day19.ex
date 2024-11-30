defmodule Day19 do
  def part1(input) do
    find_beacons(input)
    |> Enum.flat_map(fn {beacons, _} -> beacons end)
    |> Enum.uniq
    |> Enum.count
  end

  def part2(input) do
    scanners =
      find_beacons(input)
      |> Enum.map(fn {_, scanner} -> scanner end)
    Enum.reduce(scanners, 0, fn scanner1, acc ->
      Enum.reduce(scanners, acc, fn scanner2, acc ->
        max(acc, manhattan_distance(scanner1, scanner2))
      end)
    end)
  end

  def find_beacons(input) do
    [first | scanners] = parse(input)
    seeds = [first]
    combined = [{first, {0, 0, 0}}]
    combine(seeds, scanners, combined)
  end

  defp combine([seed | seeds], scanners, combined) do
    {new_seeds, scanners} = combine_one(seed, scanners, [], [])
    combined = new_seeds ++ combined
    seeds = Enum.reduce(new_seeds, seeds, fn {beacons, _}, acc ->
      [beacons | acc]
    end)
    combine(seeds, scanners, combined)
  end
  defp combine([], [], combined) do
    combined
  end

  defp combine_one(seed, [scanner | scanners], seed_acc, scan_acc) do
    case find_overlap(seed, scanner) do
      nil ->
        scan_acc = [scanner | scan_acc]
        combine_one(seed, scanners, seed_acc, scan_acc)
      {offset, beacons} ->
        seed_acc = [{beacons, offset} | seed_acc]
        combine_one(seed, scanners, seed_acc, scan_acc)
    end
  end
  defp combine_one(_seed, [], seed_acc, scan_acc) do
    {seed_acc, scan_acc}
  end

  defp find_overlap(beacons1, beacons2) do
    0..23
    |> Task.async_stream(fn n ->
      beacons2 = Enum.map(beacons2, &orientation(n, &1))
      case find_offset(beacons1, beacons2) do
        nil ->
          nil
        offset ->
          {offset, Enum.map(beacons2, &add(&1, offset))}
      end
    end, ordered: false)
    |> Enum.reduce_while(nil, fn {:ok, value}, _ ->
      if value === nil do
        {:cont, nil}
      else
        {:halt, value}
      end
    end)
  end

  defp find_offset(beacons1, beacons2) do
    Enum.flat_map(beacons1, fn pos1 ->
      Enum.map(beacons2, fn pos2 ->
        sub(pos1, pos2)
      end)
    end)
    |> Enum.frequencies
    |> Enum.reduce_while(nil, fn {offset, freq}, _ ->
      if freq >= 12 do
        {:halt, offset}
      else
        {:cont, nil}
      end
    end)
  end

  defp add({x1, y1, z1}, {x2, y2, z2}) do
    {x1 + x2, y1 + y2, z1 + z2}
  end

  defp sub({x1, y1, z1}, {x2, y2, z2}) do
    {x1 - x2, y1 - y2, z1 - z2}
  end

  defp manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  defp orientation(n, {x, y, z}) do
    case n do
      0 -> {x, y, z}
      1 -> {x, -z, y}
      2 -> {x, -y, -z}
      3 -> {x, z, -y}

      # x is facing -x
      4 -> {-x, -y, z}
      5 -> {-x, -z, -y}
      6 -> {-x, y, -z}
      7 -> {-x, z, y}

      # x is facing y
      8 -> {-z, x, -y}
      9 -> {y, x, -z}
      10 -> {z, x, y}
      11 -> {-y, x, z}

      # x is facing -y
      12 -> {z, -x, -y}
      13 -> {y, -x, z}
      14 -> {-z, -x, y}
      15 -> {-y, -x, -z}

      # x is facing z
      16 -> {-y, -z, x}
      17 -> {z, -y, x}
      18 -> {y, z, x}
      19 -> {-z, y, x}

      # x is facing -z
      20 -> {z, y, -x}
      21 -> {-y, z, -x}
      22 -> {-z, -y, -x}
      23 -> {y, -z, -x}
    end
  end

  defp parse(input) do
    input
    |> Enum.chunk_by(fn line ->
      case line do
        "---" <> _ -> true
        _ -> false
      end
    end)
    |> Enum.drop_every(2)
    |> Enum.map(fn group ->
      Enum.map(group, fn scanner ->
        String.split(scanner, ",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple
      end)
    end)
  end
end
