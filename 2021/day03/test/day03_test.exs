defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(example()) == 198
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 3374136
  end

  test "part 2 with example" do
    assert Day03.part2(example()) == 230
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 4432698
  end

  defp example() do
    """
    00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
