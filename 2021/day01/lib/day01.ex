defmodule Day01 do
  def part1(input) do
    parse(input)
    |> Enum.reduce({:infinity, 0}, fn e, {prev,acc} ->
      if e > prev do
        {e, acc + 1}
      else
        {e, acc}
      end
    end)
    |> elem(1)
  end

  def part2(input) do
    parse(input)
    |> increasing
  end

  defp increasing(input) do
    increasing(input, :infinity, 0)
  end

  defp increasing([a, b, c | tail], prev, acc) do
    sum = a + b + c
    if sum > prev do
      increasing([b, c | tail], sum, acc + 1)
    else
      increasing([b, c | tail], sum, acc)
    end
  end
  defp increasing([_ |_ ], _prev, acc), do: acc

  defp parse(input) do
    Enum.map(input, &(String.to_integer(&1)))
  end
end
