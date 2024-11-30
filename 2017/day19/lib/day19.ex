defmodule Day19 do
  def part1(input) do
    {pos, width, grid} = parse(input)
    move(:down, pos, grid, width, [])
  end

  def part2(input) do
    {pos, width, grid} = parse(input)
    move_count(:down, pos, grid, width, 0)
  end

  defp move(dir, {x, y}, grid, width, seen) do
    case :binary.at(grid, x + y * width) do
      ?| ->
        move(dir, next(dir, {x, y}), grid, width, seen)
      ?- ->
        move(dir, next(dir, {x, y}), grid, width, seen)
      ?+ ->
        dir = branch(dir, {x, y}, grid, width)
        move(dir, next(dir, {x, y}), grid, width, seen)
      letter when letter in ?A..?Z ->
        move(dir, next(dir, {x, y}), grid, width, [letter | seen])
      _ ->
        Enum.reverse(seen)
    end
  end

  defp move_count(dir, {x, y}, grid, width, steps) do
    case :binary.at(grid, x + y * width) do
      ?| ->
        move_count(dir, next(dir, {x, y}), grid, width, steps + 1)
      ?- ->
        move_count(dir, next(dir, {x, y}), grid, width, steps + 1)
      ?+ ->
        dir = branch(dir, {x, y}, grid, width)
        move_count(dir, next(dir, {x, y}), grid, width, steps + 1)
      letter when letter in ?A..?Z ->
        move_count(dir, next(dir, {x, y}), grid, width, steps + 1)
      _ ->
        steps
    end
  end

  defp next(:down, {x, y}), do: {x, y+1}
  defp next(:up, {x, y}), do: {x, y-1}
  defp next(:left, {x, y}), do: {x-1, y}
  defp next(:right, {x, y}), do: {x+1, y}

  defp branch(dir, {x, y}, grid, width) when dir === :down or dir === :up do
    case :binary.at(grid, (x - 1) + y * width) do
      ?\s -> :right
      _ -> :left
    end
  end
  defp branch(dir, {x, y}, grid, width) when dir === :left or dir === :right do
    case :binary.at(grid, x + (y - 1) * width) do
      ?\s -> :down
      _ -> :up
    end
  end

  defp parse(input) do
    lines = String.split(input, "\n")
    width = String.length(hd(lines))
    grid = to_string(lines)
    {start, _} = :binary.match(grid, "|")
    pos = {start, 0}
    {pos, width, grid}
  end
end
