defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with example" do
    assert Day24.part1(example()) == 99
  end

  test "part 1 with my input data" do
    assert Day24.part1(input()) == 10439961859
  end

  test "part 2 with example" do
    assert Day24.part2(example()) == 44
  end

  test "part 2 with my input data" do
    assert Day24.part2(input()) == 72050269
  end

  defp example() do
    """
    1
    2
    3
    4
    5
    7
    8
    9
    10
    11
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
