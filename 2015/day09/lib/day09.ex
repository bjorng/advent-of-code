defmodule Day09 do
  def part1(input) do
    solve(input, {:shortest,:infinity})
  end

  def part2(input) do
    solve(input, {:longest, -1})
  end

  defp solve(input, init_best) do
    input = parse(input)
    dist_map = Enum.map(input, fn {from, to, dist} ->
      [place1, place2] = Enum.sort([from, to])
      {{place1, place2}, dist}
    end)
    |> Map.new

    places = Enum.flat_map(input, fn {from, to, _} ->
      [from, to]
    end)
    |> Enum.uniq

    ps = permutations(places)
    {_, best} = find_best(ps, init_best, dist_map)
    best
  end

  defp find_best([p|ps], best, dist_map) do
    best = path_length(p, best, dist_map)
    find_best(ps, best, dist_map)
  end
  defp find_best([], best, _), do: best

  defp path_length([place|places], best, dist_map) do
    path_length_1(places, place, best, dist_map, 0)
  end

  defp path_length_1([place|places], place0, best, dist_map, acc) do
    acc = acc + dist(dist_map, place, place0)
    path_length_1(places, place, best, dist_map, acc)
  end
  defp path_length_1([], _, best, _, acc) do
    update_best(best, acc)
  end

  defp update_best({:shortest, best}, len) do
    {:shortest, min(best, len)}
  end
  defp update_best({:longest, best}, len) do
    {:longest, max(best, len)}
  end

  defp dist(dist_map, place0, place1) do
    if place0 < place1 do
      Map.fetch!(dist_map, {place0, place1})
    else
      Map.fetch!(dist_map, {place1, place0})
    end
  end

  def permutations([]), do: [[]]
  def permutations(list) do
    for elem <- list,
      rest <- permutations(list--[elem]) do
        [elem|rest]
    end
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      [from, "to", to, "=", distance] = String.split(line)
      {String.to_atom(from),
       String.to_atom(to),
       String.to_integer(distance)}
    end)
  end
end
