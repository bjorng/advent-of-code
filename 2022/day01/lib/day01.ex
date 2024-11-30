defmodule Day01 do
  def part1(input) do
    parse(input)
    |> Enum.map(&Enum.sum/1)
    |> Enum.max
  end

  def part2(input) do
    parse(input)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.sum
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      case Integer.parse(line) do
        :error -> :end
        {int, ""} -> int
      end
    end)
    |> Enum.chunk_by(&(&1 === :end))
    |> Enum.reject(fn
      [:end] -> true
      _ -> false
    end)
  end
end
