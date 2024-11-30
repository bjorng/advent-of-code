defmodule Day01 do
  def part1(string) do
    list = String.to_charlist(string)
    stream = Stream.drop(Stream.cycle(list), 1)
    sum(list, stream)
  end

  def part2(string) do
    middle = div(byte_size(string), 2)
    list = String.to_charlist(string)
    stream = Stream.drop(Stream.cycle(list), middle)
    sum(list, stream)
  end

  defp sum(stream1, stream2) do
    Stream.zip(stream1, stream2)
    |> Enum.reduce(0, fn
      {digit, digit}, acc -> acc + digit - ?0
      {_, _}, acc -> acc
    end)
  end
end
