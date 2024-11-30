defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part 1 with example" do
    assert Day13.part1(example()) == 17
  end

  test "part 1 with my input data" do
    assert Day13.part1(input()) == 689
  end

  test "part 2 with example" do
    Day13.part2(example())
  end

  test "part 2 with my input data" do
    Day13.part2(input())
  end

  defp example() do
    """
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
