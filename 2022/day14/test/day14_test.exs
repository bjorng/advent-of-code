defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
    assert Day14.part1(example()) == 24
  end

  test "part 1 with my input data" do
    assert Day14.part1(input()) == 1003
  end

  test "part 2 with example" do
    assert Day14.part2(example()) == 93
  end

  test "part 2 with my input data" do
    assert Day14.part2(input()) == 25771
  end

  defp example() do
    """
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
