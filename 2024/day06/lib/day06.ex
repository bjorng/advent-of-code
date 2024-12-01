defmodule Day06 do
  def part1(input) do
    {guard, grid} = parse(input)
    walk(guard, grid, MapSet.new())
    |> MapSet.size
  end

  defp walk(guard, grid, visited) do
    visited = MapSet.put(visited, elem(guard, 0))
    case one_step(guard, grid) do
      nil ->
        visited
      guard ->
        walk(guard, grid, visited)
    end
  end

  def part2(input) do
    {guard, grid} = parse(input)

    # Avoid copying the input to each worker process
    # by creating a persistent term. If we don't do
    # this, using Task.async_stream/3 would be slower
    # than sequentially trying out each obstacle position.

    :persistent_term.put(Day06, {guard, grid})

    Enum.flat_map(grid, fn {pos, what} ->
      cond do
        elem(guard, 0) === pos ->
          []
        what === ?\# ->
          []
        what === ?. ->
          [pos]
      end
    end)
    |> Task.async_stream(fn pos ->
      {guard, grid} = :persistent_term.get(Day06)
      grid = Map.put(grid, pos, ?\#)
      tortoise = guard
      hare = one_step(guard, grid)
      power = lam = 1
      case cycle?(tortoise, hare, power, lam, grid) do
        false -> 0
        true -> 1
      end
    end, ordered: false, timeout: :infinity)
    |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)
  end

  # Use the first part of Brent's cycle detection algorithm
  # (see https://en.wikipedia.org/wiki/Cycle_detection) to
  # determine whether there is a cycle.
  defp cycle?(_, nil, _, _, _), do: false
  defp cycle?(hare, hare, _, _, _), do: true
  defp cycle?(tortoise, hare, power, lam, grid) do
    {tortoise, power, lam} = if power === lam do
      {hare, 2 * power, 0}
    else
      {tortoise, power, lam}
    end
    hare = one_step(hare, grid)
    lam = lam + 1
    cycle?(tortoise, hare, power, lam, grid)
  end

  defp one_step(nil, _grid), do: nil
  defp one_step({pos, dir}, grid) do
    next = add(pos, dir)
    case grid do
      %{^next => ?.} ->
        {next, dir}
      %{^next => ?\#} ->
        dir = rotate90(dir)
        one_step({pos, dir}, grid)
      %{}->
        nil
    end
  end

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp rotate90({a, b}), do: {b, -a}

  defp parse(input) do
    grid = input
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

    {pos, _} = Enum.find(grid, fn {_, c} -> c === ?^ end)
    grid = Map.put(grid, pos, ?.)
    dir = {-1, 0}
    guard = {pos, dir}
    {guard, grid}
  end
end
