defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == 3
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == 511
  end

  test "part 2 with example" do
    assert Day05.part2(example()) == 14
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == 350939902751909
  end

  defp example() do
    """
    3-5
    10-14
    16-20
    12-18

    1
    5
    8
    11
    17
    32
    """
    |> String.split("\n\n")
    |> Enum.map(&(String.split(&1, "\n", trim: true)))
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n\n")
    |> Enum.map(&(String.split(&1, "\n", trim: true)))
  end
end
