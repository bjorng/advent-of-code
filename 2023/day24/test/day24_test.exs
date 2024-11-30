defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with example" do
    assert Day24.part1(example(), 7, 27) == 2
  end

  test "part 1 with my input data" do
    assert Day24.part1(input()) == 16665
  end

  test "part 2 with example" do
    assert Day24.part2(example()) == 47
  end

  test "part 2 with my input data" do
    assert Day24.part2(input()) == 769840447420960
  end

  defp example() do
    """
    19, 13, 30 @ -2,  1, -2
    18, 19, 22 @ -1, -1, -2
    20, 25, 34 @ -2, -2, -4
    12, 31, 28 @ -1, -2, -1
    20, 19, 15 @  1, -5, -3
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
