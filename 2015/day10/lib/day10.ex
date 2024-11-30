defmodule Day10 do
  def part1(input, times \\ 1) do
    input
    |> to_charlist
    |> Enum.map(&(&1 - ?0))
    |> Stream.iterate(&look_and_say/1)
    |> Stream.drop(times)
    |> Enum.take(1)
    |> hd
    |> Enum.map(&(&1 + ?0))
    |> List.to_string
  end

  defp look_and_say([digit | _]=digits) do
    {prefix, rest} = Enum.split_while(digits, &(&1 === digit))
    [length(prefix), digit | look_and_say(rest)]
  end
  defp look_and_say([]), do: []
end
