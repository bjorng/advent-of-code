defmodule Day09 do
  def part1(input) do
    input
    |> decompress
    |> byte_size
  end

  def part2(input) do
    decompressed_length(input)
  end

  defp decompressed_length(string), do: decompressed_length(string, 0)

  defp decompressed_length(<<>>, count), do: count
  defp decompressed_length(<<?\(, rest::binary>>, count) do
    {string, repeat, rest} = parse_marker(rest)
    count = count + repeat * decompressed_length(string, 0)
    decompressed_length(rest, count)
  end
  defp decompressed_length(<<char, rest::binary>>, count) when char in ?A..?Z  do
    decompressed_length(rest, count + 1)
  end

  def decompress(string) do
    do_decompress(string)
    |> :erlang.iolist_to_binary
  end

  def do_decompress(<<>>), do: []
  def do_decompress(<<?\(, rest::binary>>) do
    {string, repeat, rest} = parse_marker(rest)
    [List.duplicate(string, repeat) | do_decompress(rest)]
  end
  def do_decompress(<<char, rest::binary>>) when char in ?A..?Z  do
    [char | do_decompress(rest)]
  end

  defp parse_marker(rest) do
    {num_chars, rest} = Integer.parse(rest)
    <<?x, rest::binary>> = rest
    {repeat, rest} = Integer.parse(rest)
    <<?\), rest::binary>> = rest
    <<string::binary-size(num_chars), rest::binary>> = rest
    {string, repeat, rest}
  end
end
