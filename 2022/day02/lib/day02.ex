defmodule Day02 do
  def part1(input) do
    parse(input)
    |> Enum.map(&score_round/1)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {expect, ending} ->
      response = case ending do
                   0 -> response_to_lose(expect)
                   1 -> expect
                   2 -> response_to_win(expect)
                 end
      score_round({expect, response})
    end)
    |> Enum.sum
  end

  defp response_to_lose(0), do: 2
  defp response_to_lose(1), do: 0
  defp response_to_lose(2), do: 1

  defp response_to_win(0), do: 1
  defp response_to_win(1), do: 2
  defp response_to_win(2), do: 0

  defp score_round({expect, response}) do
    case {expect, response} do
      {same, same} -> 3
      {0, 1} -> 6
      {1, 2} -> 6
      {2, 0} -> 6
      {_, _} -> 0
    end + (response + 1)
  end

  defp parse(input) do
    Enum.map(input, fn <<first, ?\s, second>> ->
      {first - ?A, second - ?X}
    end)
  end
end
