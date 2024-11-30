defmodule Day03 do
  def part1(input) do
    input
    |> String.to_charlist
    |> visited_houses
    |> Enum.frequencies
    |> map_size
  end

  def part2(input) do
    {moves1, moves2} = input
    |> String.to_charlist
    |> split_moves([], [])

    Stream.concat(visited_houses(moves1), visited_houses(moves2))
    |> Enum.frequencies
    |> map_size
  end

  defp split_moves([move1, move2 | tail], acc1, acc2) do
    split_moves(tail, [move1 | acc1], [move2 | acc2])
  end
  defp split_moves([move], acc1, acc2) do
    {[move | acc1], acc2}
  end
  defp split_moves([], acc1, acc2) do
    {Enum.reverse(acc1), Enum.reverse(acc2)}
  end

  defp visited_houses(moves) do
    ' ' ++ moves
    |> Stream.scan({0, 0}, &move/2)
  end

  defp move(direction, {r, c}) do
    case direction do
      ?\s -> {r, c}
      ?^ -> {r - 1, c}
      ?v -> {r + 1, c}
      ?< -> {r, c - 1}
      ?> -> {r, c + 1}
    end
  end
end
