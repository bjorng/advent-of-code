defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(example()) == 157
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 7428
  end

  test "part 2 with example" do
    assert Day03.part2(example()) == 70
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 2650
  end

  defp example() do
    """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
