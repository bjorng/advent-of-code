defmodule Day03 do
  def part1(square) do
    spiral_positions()
    |> Stream.drop(square - 1)
    |> Enum.fetch!(0)
    |> (fn position -> manhattan_distance(position, {0, 0}) end).()
  end

  def part2(puzzle_input) do
    origin = {0, 0}
    spiral_positions()
    |> Stream.drop(1)
    |> Enum.reduce_while(%{origin => 1}, fn position, map ->
      value = neighbors(position)
      |> Stream.map(fn position -> Map.get(map, position, 0) end)
      |> Enum.sum
      if value > puzzle_input do
        {:halt, value}
      else
        {:cont, Map.put(map, position, value)}
      end
    end)
  end

  defp neighbors({a, b}) do
    [{a - 1, b - 1}, {a - 1, b}, {a - 1, b + 1},
     {a, b - 1},                 {a, b + 1},
     {a + 1, b - 1}, {a + 1, b}, {a + 1, b + 1}]
  end

  defp spiral_positions() do
    state = {1, 2, {0, 0}, {1, 0}}
    next = fn {steps, next_steps, position, direction} ->
      next_position = complex_add(position, direction)
      state =
        case (steps - 1) do
          0 ->
            next_steps = next_steps + 1
            steps = div(next_steps, 2)
            # Multiply by i to turn 90 degrees counter-clockwise.
            direction = complex_mul(direction, {0, 1})
            {steps, next_steps, next_position, direction}
          steps ->
            {steps, next_steps, next_position, direction}
        end
      {position, state}
    end
    Stream.unfold(state, next)
  end

  defp complex_add({a, b}, {c, d}) do
    {a + c, b + d}
  end

  defp complex_mul({a, b}, {c, d}) do
    {a * c - b * d, a * d + b * c}
  end

  defp manhattan_distance({a, b}, {c, d}) do
    abs(a - c) + abs(b - d)
  end
end
