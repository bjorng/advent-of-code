defmodule Day09 do
  def part1(input) do
    map = parse(input)
    Enum.reduce(map, 0, fn {coord, h}, acc ->
      nh = neighbors(map, coord)
      |> Enum.map(&(Map.fetch!(map, &1)))
      |> Enum.min
      if h < nh do
        acc + 1 + h
      else
        acc
      end
    end)
  end

  # Find the largest basin using a simple union-find algorithm.
  # The run time on my computer is less than 2 seconds.
  def part2(input) do
    map = parse(input)
    |> Enum.reject(fn {_key, value} -> value === 9 end)
    |> Map.new

    u = map
    |> Enum.map(fn {key, _} -> {key, key} end)
    |> Map.new

    Enum.reduce(u, u, fn {this, _}, acc ->
      neighbors(map, this)
      |> Enum.reduce(acc, fn neighbor, acc ->
        union(acc, this, neighbor)
      end)
    end)
    |> Enum.group_by(fn {_, value} -> value end)
    |> Enum.map(fn {_, members} -> length(members) end)
    |> Enum.sort
    |> Enum.reverse
    |> Enum.take(3)
    |> Enum.reduce(1, &(&1 * &2))
  end

  defp union(u, p, q) do
    case u do
      %{^p => t, ^q => t} ->
        u
      %{^p => t1, ^q => t2} ->
        Enum.reduce(u, u,
          fn {key, ^t1}, acc ->
            Map.put(acc, key, t2)
            _, acc ->
              acc
          end)
    end
  end

  defp neighbors(map, {row, col}) do
    [{row - 1, col},
     {row, col - 1}, {row, col + 1},
     {row + 1, col}]
     |> Enum.filter(&(Map.has_key?(map, &1)))
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      String.to_charlist(line)
      |> Enum.map(&(&1 - ?0))
    end)
    |> Enum.with_index
    |> Enum.flat_map(fn {list, row} ->
      Enum.with_index(list)
      |> Enum.map(fn {h, col} -> {{row, col}, h} end)
    end)
    |> Map.new
  end
end
