defmodule Day08 do
  def part1(input) do
    Enum.reduce(input, 0, fn string, acc ->
      acc + byte_size(string) - length(decode(string))
    end)
  end

  def part2(input) do
    Enum.reduce(input, 0, fn string, acc ->
      acc + length(encode(string)) - byte_size(string)
    end)
  end

  defp decode(string) do
    size = byte_size(string)-2
    <<?\",string::binary-size(size),?\">> = string
    decode_1(to_charlist(string))
  end

  defp decode_1(string) do
    case string do
      [?\\,?x,h1,h2|cs] ->
        [String.to_integer(<<h1,h2>>, 16)|decode_1(cs)]
      [?\\,c|cs] ->
        [c|decode_1(cs)]
      [c|cs] ->
        [c|decode_1(cs)]
      [] ->
        []
    end
  end

  defp encode(string) do
    '\"' ++ encode_1(to_charlist(string)) ++ '\"'
  end

  defp encode_1([c|cs]) do
    case c in [?\\, ?\', ?\"] do
      true ->
        [?\\, c|encode_1(cs)]
      false ->
        [c|encode_1(cs)]
    end
  end
  defp encode_1([]), do: []
end
