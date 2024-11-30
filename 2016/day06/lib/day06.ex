defmodule Day06 do
  def part1(input) do
    solve(input, &hd/1)
  end

  def part2(input) do
    solve(input, &List.last/1)
  end

  defp solve(input, choose) do
    input
    |> Enum.map(fn line ->
      String.split(line, "", trim: true)
    end)
    |> Enum.zip
    |> Enum.map(fn column ->
      column
      |> Tuple.to_list
      |> Enum.frequencies
      |> Map.to_list
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> choose.()
      |> elem(0)
    end)
    |> Enum.join
  end
end
