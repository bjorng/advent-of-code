defmodule Day12 do
  def part1(input) do
    solve(input, 1)
  end

  def part2(input) do
    solve(input, 2)
  end

  defp solve(input, max_visits) do
    pairs = parse(input)

    map = Enum.reduce(pairs, pairs, fn {from, to}, acc ->
      [{to, from} | acc]
    end)
    |> Enum.group_by(fn {from, _} -> from end)
    |> Enum.map(fn {from, destinations} ->
      {from, Enum.map(destinations, fn {_, to} -> to end)}
    end)
    |> Map.new

    seen = Map.new(map, fn {key, _} -> {key, 0} end)
    count_paths({:small, :start}, map, seen, max_visits)
  end

  defp count_paths({:small, :end}, _, _, _), do: 1
  defp count_paths(from, map, seen, max_visits) do
    seen = Map.update!(seen, from, &(&1 + 1))
    Map.fetch!(map, from)
    |> Enum.reduce(0, fn to, acc ->
      case to do
        {:small, :start} ->
          acc
        {:small, _} ->
          num_visits = Map.fetch!(seen, to)
          cond do
            num_visits === 0 ->
              acc + count_paths(to, map, seen, max_visits)
            num_visits === 1 and max_visits === 2 ->
              acc + count_paths(to, map, seen, 1)
            true ->
              acc
          end
        {:big, _} ->
          acc + count_paths(to, map, seen, max_visits)
      end
    end)
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      String.split(line, "-")
      |> Enum.map(fn cave ->
        case String.upcase(cave) === cave do
          true ->
            {:big, String.to_atom(cave)}
          false ->
            {:small, String.to_atom(cave)}
        end
      end)
      |> List.to_tuple
    end)
  end
end
