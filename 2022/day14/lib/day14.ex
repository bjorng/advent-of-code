defmodule Day14 do
  def part1(input) do
    grid = parse(input)

    max_y = Enum.map(grid, fn {{_, y}, _} -> y end)
    |> Enum.max

    Map.put(grid, :abyss, max_y + 1)

    |> Stream.iterate(fn grid -> pour_sand(grid, {500, 0}) end)
    |> Enum.find_index(&(&1 === :full))
    |> minus_one
  end

  def part2(input) do
    grid = parse(input)

    max_y = Enum.map(grid, fn {{_, y}, _} -> y end)
    |> Enum.max

    grid = Map.put(grid, :floor, max_y + 2)

    grid
    |> Stream.iterate(fn grid -> pour_sand(grid, {500, 0}) end)
    |> Enum.find_index(&(&1 === :full))
  end

  defp pour_sand(grid, position) do
    moves = [:down, :diagonally_left, :diagonally_right]
    new_position =
      Enum.find_value(moves, fn direction ->
        new_position = move(position, direction)
        case grid do
          %{^new_position => :rock} ->
            nil
          %{^new_position => :sand} ->
            nil
          %{floor: floor} when elem(new_position, 1) >= floor ->
            nil
          %{} ->
            new_position
        end
      end)
    cond do
      new_position === nil ->
        if position === {500, 0} do
          :full
        else
          Map.put(grid, position, :sand)
        end
      elem(new_position, 1) >= Map.get(grid, :abyss, :infinity) ->
        :full
      true ->
        pour_sand(grid, new_position)
    end
  end

  defp move({x, y}, direction) do
    case direction do
      :down ->
        {x, y + 1}
      :diagonally_left ->
        {x - 1, y + 1}
      :diagonally_right ->
        {x + 1, y + 1}
    end
  end

  defp minus_one(n), do: n - 1

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, " -> ")
      |> Enum.map(fn coordinates ->
      String.split(coordinates, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
    end)
    |> to_grid
  end

  defp to_grid(groups) do
    Enum.flat_map(groups, fn coordinates ->
      make_lines(coordinates)
    end)
    |> Enum.map(&({&1, :rock}))
    |> Map.new
  end

  defp make_lines([{x, y1}, {x, y2} | coordinates]) do
    Enum.map(min(y1, y2)..max(y1, y2), &({x, &1})) ++
      make_lines([{x, y2} | coordinates])
  end
  defp make_lines([{x1, y}, {x2, y} | coordinates]) do
    Enum.map(min(x1, x2)..max(x1, x2), &({&1, y})) ++
      make_lines([{x2, y} | coordinates])
  end
  defp make_lines([_]), do: []
end
