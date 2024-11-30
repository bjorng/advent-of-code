defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "part 1 with example" do
    assert Day04.part1(example()) == 13
  end

  test "part 1 with my input data" do
    assert Day04.part1(input()) == 21959
  end

  test "part 2 with example" do
    assert Day04.part2(example()) == 30
  end

  test "part 2 with my input data" do
    assert Day04.part2(input()) == 5132675
  end

  defp example() do
    """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
