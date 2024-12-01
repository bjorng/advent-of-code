defmodule Day08 do
  def part1(input) do
    solve(input, &find_antinodes_part1/3)
  end

  defp find_antinodes_part1(map, a, b) do
    [add(a, sub(a, b)), add(b, sub(b, a))]
    |> Enum.filter(&Map.has_key?(map, &1))
  end

  def part2(input) do
    solve(input, &find_antinodes_part2/3)
  end

  defp find_antinodes_part2(map, a, b) do
    {da, db} = sub(a, b)
    gcd = Integer.gcd(da, db)
    dir = {div(da, gcd), div(db, gcd)}
    Stream.concat(iter(a, dir, map), iter(a, rotate180(dir), map))
  end

  defp iter(position, direction, map) do
    Stream.unfold(position, fn position ->
      if Map.has_key?(map, position) do
        new_position = add(position, direction)
        {position, new_position}
      else
        nil
      end
    end)
  end

  def solve(input, find_antinodes) do
    map = parse(input)

    map
    |> Enum.reject(fn {_, freq} -> freq === ?. end)
    |> Enum.group_by(fn {_where, freq} -> freq end)
    |> Enum.flat_map(fn {_, group} ->
      Enum.map(group, fn {where, _} -> where end)
      |> pairs
      |> Enum.flat_map(fn {a, b} ->
        find_antinodes.(map, a, b)
      end)
    end)
    |> Enum.uniq
    |> Enum.count
  end

  defp pairs([_]), do: []
  defp pairs([head | tail]) do
    Enum.map(tail, &{head, &1}) ++ pairs(tail)
  end

  defp sub({a, b}, {c, d}), do: {a - c, b - d}

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp rotate180({a, b}), do: {-a, -b}

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> Map.new
  end

  def print_grid(antinodes, map) do
    map = Enum.reduce(antinodes, map, fn position, map ->
      if Map.fetch!(map, position) === ?. do
        Map.put(map, position, ?\#)
      else
        map
      end
    end)
    print_grid(map)
    antinodes
  end

  def print_grid(map) do
    :io.nl
    {{min_row, _}, {max_row, _}} = Enum.min_max_by(Map.keys(map), &elem(&1, 0))
    {{_, min_col}, {_, max_col}} = Enum.min_max_by(Map.keys(map), &elem(&1, 1))
    Enum.each(min_row..max_row, fn row ->
      Enum.each(min_col..max_col, fn col ->
        position = {row, col}
        :io.put_chars([Map.fetch!(map, position)])
      end)
      :io.nl
    end)
    :io.nl
    map
  end
end
