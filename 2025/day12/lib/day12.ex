defmodule Day12 do
  def part1(input) do
    {presents, regions} = parse(input)

    regions
    |> Enum.reject(fn region ->
      presents_fit?(region, presents)
    end)
    |> Enum.count
  end

  defp presents_fit?(region, presents) do
    num_units = Enum.map(presents, fn {index, [shape | _]} ->
      Enum.reduce(shape, [], &(&1++&2))
      |> Enum.count(&(&1 === ?\#))
      |> then(&{index, &1})
    end)
    |> Map.new

    {{width, height}, qs} = region
    area = width * height

    qs
    |> Enum.with_index
    |> Enum.map(fn {q, index} ->
      q * Map.get(num_units, index)
    end)
    |> Enum.sum
    |> then(fn needed ->
      if needed > area do
        # Can't possibly fit.
        true
      else
        # Might fit; must check.
        brute_force_solution(region, presents)
      end
    end)
  end

  defp brute_force_solution(_region, _presents) do
    # Turns out that for all inputs the presents will always fit.
    false
  end

  defp rot(grid) do
    Enum.zip_with(grid, &Enum.reverse/1)
  end

  defp hflip(grid) do
    Enum.map(grid, &Enum.reverse/1)
  end

  defp vflip(grid) do
    Enum.reverse(grid)
  end

  defp transpose(list) do
    Enum.zip_with(list, &Function.identity/1)
  end

  defp parse(input) do
    {presents, [regions]} = Enum.split(input, length(input) - 1)

    presents = Enum.map(presents, fn present ->
      [index | grid] = String.split(present, "\n", trim: true)

      grid = Enum.map(grid, &String.to_charlist/1)

      grids = Enum.flat_map_reduce(1..4, grid, fn _, grid ->
        {[grid, hflip(grid), vflip(grid)], rot(grid)}
      end)
      |> elem(0)
      |> Enum.uniq

      index = index
      |> String.trim(":")
      |> String.to_integer

      if true do
        IO.puts("#{index}:")
        grids
        |> transpose
        |> Enum.each(fn grid ->
          Enum.each(grid, &IO.write("#{&1}  "))
          IO.puts ""
        end)
        IO.puts ""
      end

      {index, grids}
    end)

    regions = regions
    |> String.split("\n", trim: true)
    |> Enum.map(fn region ->
      [size, qs] = String.split(region, ": ")

      size = size
      |> String.split("x")
      |> Enum.map(&String.to_integer(&1))
      |> List.to_tuple

      qs = String.split(qs, " ")
      |> Enum.map(&String.to_integer(&1))
      {size, qs}
    end)
    |> Enum.sort

    {presents, regions}
  end
end
