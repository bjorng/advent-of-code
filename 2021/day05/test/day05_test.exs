defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == 5
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == 6710
  end

  test "part 2 with example" do
    assert Day05.part2(example()) == 12
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == 20121
  end

  defp example() do
    """
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
