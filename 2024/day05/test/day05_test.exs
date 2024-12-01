defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == 143
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == 4790
  end

  test "part 2 with example" do
    assert Day05.part2(example()) == 123
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == 6319
  end

  defp example() do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
