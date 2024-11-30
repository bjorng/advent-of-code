defmodule Day08 do
  def part1(input) do
    grid = parse(input)
    Enum.count(grid, fn {position, height} ->
      is_visible?(grid, position, height)
    end)
  end

  defp is_visible?(grid, position, height) do
    Enum.any?(directions(),
      fn direction ->
        is_visible?(grid, position, direction, height)
      end)
  end

  defp is_visible?(grid, position, direction, height) do
    neighbor = add(position, direction)
    case Map.get(grid, neighbor, -1) do
      -1 ->
        true
      h when h < height ->
        is_visible?(grid, neighbor, direction, height)
      _ ->
        false
    end
  end

  def part2(input) do
    grid = parse(input)
    Enum.map(grid, fn {position, height} ->
      scenic_score(grid, position, height)
    end)
    |> Enum.max
  end

  defp scenic_score(grid, position, height) do
    Enum.map(directions(),
      fn direction ->
        scenic_score(grid, position, direction, height, 0)
      end)
      |> Enum.product
  end

  defp scenic_score(grid, position, direction, height, score) do
    neighbor = add(position, direction)
    case grid do
      %{^neighbor => h} when h < height ->
        scenic_score(grid, neighbor, direction, height, score + 1)
      %{^neighbor => _} ->
        score + 1
      %{} ->
        score
    end
  end

  defp directions() do
    [{-1, 0},
     {0, -1}, {0, 1},
     {1, 0}]
  end

  defp add({row, col}, {delta_row, delta_col}) do
    {row + delta_row, col + delta_col}
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.reduce(%{}, fn
      {line, row}, grid ->
        String.to_charlist(line)
        |> Enum.map(fn c -> c - ?0 end)
        |> Enum.with_index
        |> Enum.reduce(grid, fn {height, col}, grid ->
        Map.put(grid, {row, col}, height)
      end)
    end)
  end
end
