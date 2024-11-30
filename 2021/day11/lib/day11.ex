defmodule Day11 do
  def part1(input, steps \\ 100) do
    grid = parse(input)

    Stream.iterate({grid, 0}, &next_step/1)
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> hd
    |> elem(1)
  end

  def part2(input) do
    grid = parse(input)

    Stream.iterate({grid, 0}, &next_step/1)
    |> Stream.with_index
    |> Stream.drop_while(fn {{grid, _}, _} ->
      Enum.any?(grid, fn {_, level} -> level != 0 end)
    end)
    |> Enum.take(1)
    |> hd
    |> elem(1)
  end

  defp next_step({grid, num_flashes}) do
    grid = grid
    |> Enum.map(fn {key, level} -> {key, level + 1} end)
    |> Map.new

    flashes = Enum.filter(Map.keys(grid), fn key ->
      Map.fetch!(grid, key) > 9
    end)

    num_flashes = num_flashes + length(flashes)

    {grid, num_flashes} = flash(grid, flashes, num_flashes)

    grid = Enum.reduce(grid, grid, fn {key, level}, acc ->
      if level < 0 do
        Map.put(acc, key, 0)
      else
        acc
      end
    end)

    {grid, num_flashes}
  end

  defp flash(grid, [_ | _] = flashes, num_flashes) do
    grid = Enum.reduce(flashes, grid, fn key, grid ->
      Map.put(grid, key, -1_000_000)
    end)
    acc = {grid, []}
    {grid, flashes} = Enum.reduce(flashes, acc, &flash_one/2)
    flashes = Enum.uniq(flashes)
    flash(grid, flashes, num_flashes + length(flashes))
  end
  defp flash(grid, [], num_flashes), do: {grid, num_flashes}

  defp flash_one(key, {grid, flashes}) do
    Enum.reduce(neighbors(grid, key), {grid, flashes},
      fn neighbor, {grid, flashes} ->
        level = Map.fetch!(grid, neighbor) + 1
        grid = Map.put(grid, neighbor, level)
        flashes = if level > 9, do: [neighbor | flashes], else: flashes
        {grid, flashes}
      end)
  end

  defp neighbors(map, {row, col}) do
    [{row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
     {row, col - 1},                     {row, col + 1},
     {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}]
     |> Enum.filter(&(Map.has_key?(map, &1)))
  end

  def print_grid(grid) do
    Enum.map(0..9, fn row ->
      [Enum.map(0..9, fn col ->
          key = {row, col}
          level = Map.fetch!(grid, key)
          cond do
            level < 0 -> ?\-
            level === 0 -> ?\*
            level > 9 -> ?\+
            true -> ?0 + level
          end
        end), ?\n]
    end)
    |> :io.put_chars
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
