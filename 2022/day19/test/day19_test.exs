defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with example" do
    assert Day19.part1(example()) == 33
  end

  test "part 1 with my input data" do
    assert Day19.part1(input()) == 2160
  end

  test "part 2 with example" do
    assert Day19.part2(example()) == 56 * 62
  end

  test "part 2 with my input data" do
    assert Day19.part2(input()) == 13340
  end

  defp example() do
    """
    Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
