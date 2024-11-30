defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with examples" do
    assert Day24.part1(example1()) == 2129920
  end

  test "part 1 with my input" do
    assert Day24.part1(input()) == 24662545
  end

  test "part 2 with examples" do
    assert Day24.part2(example1(), 10) == 99
  end

  test "part 2 with my input" do
    assert Day24.part2(input()) == 2063
  end

  defp example1() do
    """
    ....#
    #..#.
    #..##
    ..#..
    #....
    """
    |> String.split
  end

  defp input do
    File.read!('input.txt')
    |> String.split("\n")
  end
end
