defmodule Day14 do
  use Bitwise

  def part1(input) do
    0..127
    |> Stream.map(fn n ->
      input <> "-" <> Integer.to_string(n)
    end)
    |> Stream.map(&KnotHash.hash/1)
    |> Stream.map(fn h ->
      count_bits(h, 128, 0)
    end)
    |> Enum.reduce(&+/2)
  end

  def part2(input) do
    chart = 0..127
    |> Stream.map(fn n ->
      input <> "-" <> Integer.to_string(n)
    end)
    |> Stream.map(&KnotHash.hash/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {n, row} ->
      {used, _} =
	Enum.reduce(0..127, {[], n} , fn col, {acc, n} ->
	  case band(n, 1) do
	    0 -> {acc, n >>> 1};
	    1 -> {[{{row, col}, :used} | acc], n >>> 1}
	  end
	end)
      used
    end)
    |> Map.new
    count_regions(chart, 0)
  end

  defp count_bits(_n, 0, acc), do: acc
  defp count_bits(n, left, acc) do
    count_bits(n >>> 1, left - 1, acc + band(n, 1))
  end

  defp count_regions(chart, num_regions) do
    case Map.keys(chart) do
      [pos | _] ->
	chart = remove_region(chart, pos)
	count_regions(chart, num_regions + 1)
      [] ->
	num_regions
    end
  end

  defp remove_region(chart, pos) do
    case Map.has_key?(chart, pos) do
      false ->
	chart
      true ->
	chart = Map.drop(chart, [pos])
	Enum.reduce(neighbors(pos), chart, fn pos, chart ->
	  remove_region(chart, pos)
	end)
    end
  end

  defp neighbors({row, col}) do
    [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
  end
end

defmodule KnotHash do
  use Bitwise

  def hash(string) do
    lengths = :erlang.binary_to_list(string) ++ [17, 31, 73, 47, 23]
    state = new_state()
    state = Enum.reduce(1..64, state, fn _, acc ->
      Enum.reduce(lengths, acc, &tie/2)
    end)
    sparse_hash = rotate(state)
    {hashes, []} = Enum.map_reduce(1..16, sparse_hash, fn _, acc ->
      {block, acc} = Enum.split(acc, 16)
      hash = Enum.reduce(block, &Bitwise.bxor/2)
      {hash, acc}
    end)
    Enum.reduce(hashes, 0, fn h, acc ->
      bor(acc <<< 8, h)
    end)
  end

  defp new_state(length \\ 256) do
    %{list: Enum.to_list(0..length-1),
      skip_size: 0,
      current_pos: 0}
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
end
