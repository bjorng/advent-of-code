defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 3749
  end

  test "part 1 with my input data" do
    assert Day07.part1(input()) == 3351424677624
  end

  test "part 2 with example" do
    assert Day07.part2(example()) == 11387
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 204976636995111
  end

  defp example() do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
