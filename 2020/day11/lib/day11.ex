defmodule Day11 do
  def part1(input) do
    solve(input, &update_grid_part1/2)
  end

  def part2(input) do
    solve(input, &update_grid_part2/2)
  end

  def solve(input, update) do
    grid = parse(input)
    seats = Map.keys(grid)
    Stream.iterate(grid, fn grid ->
      update.(grid, seats)
    end)
    |> Enum.reduce_while(nil, fn
      grid, grid -> {:halt, grid}
      grid, _prev -> {:cont, grid}
    end)
    |> Enum.count(fn {_, state} -> state === :occupied end)
  end

  defp update_grid_part1(grid, seats) do
    Enum.map(seats, fn location ->
      num_occupied = count_occupied_neigbors(grid, location)
      state = case Map.get(grid, location) do
                :empty when num_occupied === 0 -> :occupied
                :occupied when num_occupied >= 4 -> :empty
                state -> state
              end
      {location, state}
    end)
    |> Map.new
  end

  defp update_grid_part2(grid, seats) do
    Enum.map(seats, fn location ->
      num_occupied = count_occupied_neigbors(grid, location, :floor)
      state = case Map.get(grid, location) do
                :empty when num_occupied === 0 -> :occupied
                :occupied when num_occupied >= 5 -> :empty
                state -> state
              end
      {location, state}
    end)
    |> Map.new
  end

  defp count_occupied_neigbors(grid, location, ignore \\ nil) do
    [{-1, -1}, {0, -1}, {1, -1},
     {-1,  0},          {1,  0},
     {-1,  1}, {0,  1}, {1,  1}]
     |> Enum.reduce(0, fn direction, acc ->
      case find_neighbor(grid, location, direction, ignore) do
        :occupied -> acc + 1
        :empty -> acc
        :floor -> acc
        :outside -> acc
      end
    end)
  end

  defp find_neighbor(grid, location, direction, ignore) do
    location = vec_add(location, direction)
    case Map.get(grid, location, :outside) do
      ^ignore -> find_neighbor(grid, location, direction, ignore)
      other -> other
    end
  end

  defp vec_add({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp parse(input) do
    init = {{0, 0}, %{}}
    {_, grid} =
      input
      |> Enum.reduce(init, fn row, {{x, y}, grid} ->
      {_, grid} = row
      |> String.to_charlist()
      |> Enum.reduce({x, grid}, fn char, {x, grid} ->
        grid = case char do
                 ?L ->
                   Map.put(grid, {x, y}, :empty)
                 ?. ->
                   Map.put(grid, {x, y}, :floor)
               end
        {x + 1, grid}
      end)
      {{x, y + 1}, grid}
    end)
    grid
  end
end
