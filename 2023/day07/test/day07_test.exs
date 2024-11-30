defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 6440
  end

  test "part 1 with my input data" do
    assert Day07.part1(input()) == 250946742
  end

  test "part 2 with example" do
    assert Day07.part2(example()) == 5905
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 251824095
  end

  defp example() do
    """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
