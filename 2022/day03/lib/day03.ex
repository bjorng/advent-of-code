defmodule Day03 do
  def part1(input) do
    input
    |> Enum.map(fn contents ->
      len = String.length(contents)
      {part1, part2} = Enum.split(String.to_charlist(contents), div(len, 2))
      [part1, part2]
    end)
    |> solve
  end

  def part2(input) do
    input
    |> Enum.map(&String.to_charlist/1)
    |> Enum.chunk_every(3)
    |> solve
  end

  defp solve(parts) do
    parts
    |> Enum.map(fn parts ->
      [part | parts] = Enum.map(parts, &MapSet.new/1)
      Enum.reduce(parts, part, &MapSet.intersection/2)
      |> MapSet.to_list
      |> hd
      |> priority
    end)
    |> Enum.sum
  end

  defp priority(c) do
    cond do
      c in ?a..?z ->
        c - ?a + 1
      c in ?A..?Z ->
        c - ?A + 27
    end
  end
end
