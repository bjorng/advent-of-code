defmodule Day10 do
  use Bitwise

  def part1(length, lengths_string) do
    lengths = lengths_string
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    state = new_state(length)
    Enum.reduce(lengths, state, &tie/2)
    |> result
  end

  def part2(string) do
    lengths = :erlang.binary_to_list(string) ++ [17, 31, 73, 47, 23]
    state = new_state()
    state = Enum.reduce(1..64, state, fn _, acc ->
      Enum.reduce(lengths, acc, &tie/2)
    end)
    knot_hash(state)
  end

  defp new_state(length \\ 256) do
    %{list: Enum.to_list(0..length-1),
      skip_size: 0,
      current_pos: 0}
  end

  defp knot_hash(state) do
    sparse_hash = rotate(state)
    {hex_digits, []} = Enum.map_reduce(1..16, sparse_hash, fn _, acc ->
      {block, acc} = Enum.split(acc, 16)
      hash = Enum.reduce(block, &Bitwise.bxor/2)
      "1" <> hex = Integer.to_string(hash + 0x100, 16)
      {String.downcase(hex), acc}
    end)
    :erlang.iolist_to_binary(hex_digits)
  end

  defp tie(length, state) do
    %{list: list, skip_size: skip_size, current_pos: current_pos} = state

    {first, last} = Enum.split(list, length)
    list = last ++ Enum.reverse(first)

    {first, last} = Enum.split(list, skip_size)
    list = last ++ first

    current_pos = current_pos + length + skip_size
    %{state | list: list, skip_size: rem(skip_size + 1, 256), current_pos: current_pos}
  end

  defp rotate(state) do
    %{list: list, current_pos: current_pos} = state
    current_pos = rem(current_pos, length(list))
    {first, last} = Enum.split(list, - current_pos)
    last ++ first
  end

  defp result(state) do
    [a, b | _] = rotate(state)
    a * b
  end
end
