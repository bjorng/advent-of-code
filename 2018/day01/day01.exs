#
# To run tests:
#
#    elixir day01.exs
#
# To run part 1 and 2:
#
#    > iex day01.exs
#    [iex]> Day01.part1
#    [iex]> Day01.part2
#

defmodule Day01 do
  def part1, do: sum_freq()
  def part2, do: freq_twice()

  def sum_freq() do
    sum_freq(int_stream("input.txt"))
  end

  def freq_twice() do
    freq_twice(int_stream("input.txt"))
  end

  def sum_freq(stream) do
    Enum.reduce(stream, 0, &+/2)
  end

  def int_stream(f) do
    File.stream!(f)
    |> Enum.map(fn line -> String.to_integer(String.trim(line)) end)
  end

  def freq_twice(stream) do
    Stream.cycle(stream)
    |> Stream.transform(0, fn i, acc -> {[acc], acc + i} end)
    |> Enum.reduce_while(MapSet.new(), fn int, seen ->
      if MapSet.member?(seen, int) do
	{:halt, int}
      else
	{:cont, MapSet.put(seen, int)}
      end
    end)
  end

end

ExUnit.start()

defmodule Day01Test do
  use ExUnit.Case

  import Day01

  test "part one" do
    assert sum_freq([1, -2, 3, 1]) == 3
    assert sum_freq([1, 1, 1]) == 3
    assert sum_freq([1, 1, -2]) == 0
    assert sum_freq([-1, -2, -3]) == -6
    assert sum_freq() == 518
  end

  test "part two" do
    assert freq_twice([1, -2, 3, 1]) == 2
    assert freq_twice([1, -1]) == 0
    assert freq_twice([3, 3, 4, -2, -4]) == 10
    assert freq_twice([-6, 3, 8, 5, -6]) == 5
    assert freq_twice([7, 7, -2, -7, -4]) == 14
    assert freq_twice() == 72889
  end

end
