defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1(example()) == 7
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 1400
  end

  test "part 2 with example" do
    assert Day01.part2(example()) == 5
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 1429
  end

  defp example() do
    """
    199
    200
    208
    210
    200
    207
    240
    269
    260
    263
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
