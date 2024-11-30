defmodule Day16 do
  def part1(input, size \\ 272) do
    input
    |> gen_dragon(size)
    |> checksum
  end

  def part2(input) do
    size = 35651584
    input
    |> gen_dragon(size)
    |> checksum
  end

  defp gen_dragon(data, size) do
    if byte_size(data) < size do
      data = data <> "0" <> dragon_rev(data, "")
      gen_dragon(data, size)
    else
      <<data::binary-size(size), _::binary>> = data
      data
    end
  end

  defp dragon_rev(<<>>, acc), do: List.to_string(acc)
  defp dragon_rev(<<?0::size(8), rest::binary>>, acc) do
    dragon_rev(rest, [?1 | acc])
  end
  defp dragon_rev(<<?1::size(8), rest::binary>>, acc) do
    dragon_rev(rest, [?0 | acc])
  end

  @doc """
    iex> Day16.checksum("110010110100")
    "100"
  """
  def checksum(string) do
    if rem(byte_size(string), 2) === 0 do
      checksum(string, "")
      |> checksum
    else
      string
    end
  end

  def checksum(<<>>, result), do: result
  def checksum(<<c1::size(8), c2::size(8), rest::binary>>, result) do
    if c1 === c2 do
      checksum(rest, result <> "1")
    else
      checksum(rest, result <> "0")
    end
  end
end
