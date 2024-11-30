defmodule Day18 do
  def part1(input) do
    parse(input)
    |> Enum.map(fn {dir, steps, _} -> {dir, steps} end)
    |> solve
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {_, _, hex} ->
      {steps, command} = String.split_at(hex, 5)
      steps = String.to_integer(steps, 16)
      {case command do
         "0" -> :R
         "1" -> :D
         "2" -> :L
         "3" -> :U
       end, steps}
    end)
    |> solve
  end

  defp solve(commands) do
    perimeter = commands
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum

    commands
    |> Enum.map_reduce({0, 0}, fn {dir, steps}, pos ->
      new_pos = add(pos, offset(dir, steps))
      {pos, new_pos}
    end)
    |> then(&elem(&1, 0))
    |> shoelace
    |> then(fn area ->
      # Pick's theorem
      area + div(perimeter, 2) + 1
    end)
  end

  defp shoelace(coordinates) do
    coordinates ++ [hd(coordinates)]
    |> shoelace(0)
  end

  defp shoelace([_], sum), do: div(abs(sum), 2)
  defp shoelace([{row1, col1}, {row2, col2} | rest], sum) do
    det = col2 * row1 - row2 * col1
    shoelace([{row2, col2} | rest], sum + det)
  end

  defp offset(atom, steps) do
    case atom do
      :R -> {0, steps}
      :D -> {steps, 0}
      :L -> {0, -steps}
      :U -> {-steps, 0}
    end
  end

  defp add({row0, col0}, {row1, col1}) do
    {row0 + row1, col0 + col1}
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [dir, distance, hex] = String.split(line, " ")
      [hex] = String.split(hex, ["(", ")", "#"], trim: true)
      {String.to_atom(dir), String.to_integer(distance), hex}
    end)
  end
end
