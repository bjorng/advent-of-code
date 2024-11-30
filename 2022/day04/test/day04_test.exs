defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "part 1 with example" do
    assert Day04.part1(example()) == 2
  end

  test "part 1 with my input data" do
    assert Day04.part1(input()) == 536
  end

  test "part 2 with example" do
    assert Day04.part2(example()) == 4
  end

  test "part 2 with my input data" do
    assert Day04.part2(input()) == 845
  end

  defp example() do
    """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
