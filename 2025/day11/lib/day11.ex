defmodule Day11 do
  def part1(input) do
    map = parse(input)
    count_paths(map, "you")
  end

  defp count_paths(_map, "out"), do: 1
  defp count_paths(map, label) do
    Enum.reduce(Map.get(map, label), 0, fn label, count ->
      count + count_paths(map, label)
    end)
  end

  def part2(input) do
    map = parse(input)
    count_paths_part2(map, "svr", 0, MapSet.new())
    |> elem(0)
  end

  defp count_paths_part2(_map, "out", flags, memo) do
    n = if seen_both?(flags), do: 1, else: 0
    {n, memo}
  end
  defp count_paths_part2(map, label, seen, memo) do
    seen = update_seen(seen, label)
    key = {label, seen}
    case memo do
      %{^key => n} ->
        {n, memo}
      %{} ->
        Enum.reduce(Map.get(map, label), {0, memo}, fn label, {count, memo} ->
          {new_count, memo} = count_paths_part2(map, label, seen, memo)
          {count + new_count, memo}
        end)
        |> then(fn {count, memo} ->
          {count, Map.put(memo, key, count)}
        end)
    end
  end

  defp update_seen(seen, "fft"), do: Bitwise.bor(seen, 1)
  defp update_seen(seen, "dac"), do: Bitwise.bor(seen, 2)
  defp update_seen(seen, _), do: seen

  defp seen_both?(flags), do: flags === 3

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [label | outs] = String.split(line, [": ", " "])
      {label, outs}
    end)
    |> Map.new
  end
end
