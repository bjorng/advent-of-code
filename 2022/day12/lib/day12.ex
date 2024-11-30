defmodule Day12 do
  def part1(input) do
    grid = parse(input)
    %{start: from, target: to} = grid
    distance = manhattan_distance(from, to)
    steps = 0
    q = :gb_sets.singleton({steps, distance, from})
    seen = MapSet.new
    find_path(grid, q, seen, to)
  end

  def part2(input) do
    grid = parse(input)
    %{target: to} = grid
    q = Enum.flat_map(grid, fn
      {position, 0} ->
        [{0, manhattan_distance(position, to), position}]
      _ ->
        []
    end)
    |> :gb_sets.from_list
    seen = MapSet.new
    find_path(grid, q, seen, to)
  end

  defp find_path(grid, q, seen, to) do
    {{steps, _, position}, q} = :gb_sets.take_smallest(q)
    if position === to do
      steps
    else
      steps = steps + 1
      max_height = Map.fetch!(grid, position) + 1
      {q, seen} =
        Enum.reduce(neighbors(position), {q, seen}, fn neighbor, {q, seen} ->
          case grid do
            %{^neighbor => h} when h <= max_height ->
              case MapSet.member?(seen, neighbor) do
                true ->
                  {q, seen}
                false ->
                  key = {steps, manhattan_distance(neighbor, to), neighbor}
                  {:gb_sets.add(key, q), MapSet.put(seen, neighbor)}
              end
            %{} ->
              {q, seen}
          end
        end)
      find_path(grid, q, seen, to)
    end
  end

  defp neighbors({row, col}) do
    [{row - 1, col},
     {row, col - 1}, {row, col + 1},
     {row + 1, col}]
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.reduce(%{}, fn
      {line, row}, grid ->
        String.to_charlist(line)
        |> Enum.map(fn c -> c - ?a end)
        |> Enum.with_index
        |> Enum.reduce(grid, fn {height, col}, grid ->
        position = {row, col}
        {grid, height} =
          case (height + ?a) do
            ?S ->
              {Map.put(grid, :start, position), 0}
            ?E ->
              {Map.put(grid, :target, position), 25}
            _ ->
              {grid, height}
          end
        Map.put(grid, position, height)
      end)
    end)
  end
end
