defmodule Day04 do
  def part1(input) do
    find_coin(input, 20)
  end

  def part2(input) do
    find_coin(input, 24)
  end

  defp find_coin(key, zeroes) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.drop_while(fn index ->
      case :erlang.md5([key | Integer.to_string(index)]) do
        <<0::size(zeroes), _::bitstring>> ->
          false
        _ ->
          true
      end
    end)
    |> Enum.take(1)
    |> hd
  end

end
