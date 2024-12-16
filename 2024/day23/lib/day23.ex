defmodule Day23 do
  def part1(input) do
    pre_filter = &match?([_, _], &1)
    solve(input, pre_filter)
    |> Enum.filter(fn set ->
      Enum.any?(set, &match?("t" <> _, Atom.to_string(&1)))
    end)
    |> Enum.count
  end

  def part2(input) do
    pre_filter = &match?([_, _, _ | _], &1)
    solve(input, pre_filter)
    |> Enum.max_by(&length(&1))
    |> then(fn computers ->
      computers
      |> Enum.map(&Atom.to_string/1)
      |> Enum.join(",")
    end)
  end

  def solve(input, pre_filter) do
    connections = parse(input)
    |> Enum.flat_map(fn {a, b} ->
      [{a, b}, {b, a}]
    end)
    |> Enum.uniq
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {v, reachable} ->
      {v, Enum.map(reachable, &elem(&1, 1))}
    end)
    |> Map.new

    connections
    |> Enum.flat_map_reduce(0, fn {from, vs}, max_set_size ->
      new_sets = combinations(vs)
      |> Enum.filter(pre_filter)
      |> Enum.filter(fn computers ->
        (length(computers) + 1 >= max_set_size) and
        all_connected?(connections, computers)
      end)
      |> Enum.map(&Enum.sort([from|&1]))
      max_set_size = max(max_set_size,
        Enum.max(Enum.map(new_sets, &length/1), fn -> 0 end))
      {new_sets, max_set_size}
    end)
    |> elem(0)
    |> Enum.uniq
  end

  defp all_connected?(_connections, []), do: true
  defp all_connected?(connections, [c1|computers]) do
    Enum.all?(computers, fn c2 ->
      has_connection?(connections, c1, c2)
    end) and all_connected?(connections, computers)
  end

  defp has_connection?(connections, a, b) do
    Enum.member?(Map.fetch!(connections, a), b)
  end

  defp combinations([head | tail]) do
    cs = combinations(tail)
    for c <- cs do [head | c] end ++ cs
  end
  defp combinations([]), do: [[]]


  defp parse(input) do
    input
    |> Enum.map(fn line ->
      <<a::binary-size(2), "-", b::binary-size(2)>> = line
      {String.to_atom(a), String.to_atom(b)}
    end)
  end
end
