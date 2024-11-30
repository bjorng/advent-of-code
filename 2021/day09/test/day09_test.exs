defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example()) == 15
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 572
  end

  test "part 2 with example" do
    assert Day09.part2(example()) == 1134
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 847044
  end

  defp example() do
    """
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
