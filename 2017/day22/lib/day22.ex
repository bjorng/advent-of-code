defmodule Day22 do
  def part1(input, moves \\ 10000) do
    grid = parse(input)
    |> Map.new
    state = {{0, 0}, 0, 0, grid}

    res = Stream.iterate(state, &next_state_part1/1)
    |> Stream.drop(moves)
    |> Enum.take(1)
    |> hd

    {_, _, infections, _} = res
    infections
  end

  def part2(input, moves \\ 10000000) do
    grid = parse(input)
    |> Map.new
    state = {{0, 0}, 0, 0, grid}

    res = Stream.iterate(state, &next_state_part2/1)
    |> Stream.drop(moves)
    |> Enum.take(1)
    |> hd

    {_, _, infections, _} = res
    infections
  end

  defp next_state_part1({location, direction, infections, grid}) do
    case Map.get(grid, location, :clean) do
      :infected ->
        direction = turn_right(direction)
        grid = Map.put(grid, location, :clean)
        location = move(location, direction)
        {location, direction, infections, grid}
      :clean ->
        direction = turn_left(direction)
        grid = Map.put(grid, location, :infected)
        infections = infections + 1
        location = move(location, direction)
        {location, direction, infections, grid}
    end
  end

  defp next_state_part2({location, direction, infections, grid}) do
    case Map.get(grid, location, :clean) do
      :infected ->
        direction = turn_right(direction)
        grid = Map.put(grid, location, :flagged)
        location = move(location, direction)
        {location, direction, infections, grid}
      :clean ->
        direction = turn_left(direction)
        grid = Map.put(grid, location, :weakened)
        location = move(location, direction)
        {location, direction, infections, grid}
      :flagged ->
        direction = direction |> turn_left |> turn_left
        grid = Map.put(grid, location, :clean)
        location = move(location, direction)
        {location, direction, infections, grid}
      :weakened ->
        grid = Map.put(grid, location, :infected)
        infections = infections + 1
        location = move(location, direction)
        {location, direction, infections, grid}
    end
  end

  defp turn_left(direction) do
    rem(4 + direction - 1, 4)
  end

  defp turn_right(direction) do
    rem(4 + direction + 1, 4)
  end

  defp move({x, y}, direction) do
    case direction do
      0 -> {x, y - 1}
      2 -> {x, y + 1}
      1 -> {x + 1, y}
      3 -> {x - 1, y}
    end
  end

  defp parse(input) do
    middle = div(length(input), 2)

    input
    |> Enum.with_index(-middle)
    |> Enum.flat_map(fn {line, y} ->
      String.to_charlist(line)
      |> Enum.with_index(-middle)
      |> Enum.map(fn {char, x} ->
        location = {x, y}
        state = case char do
                  ?\# -> :infected
                  ?\. -> :clean
                end
        {location, state}
      end)
    end)
  end
end
