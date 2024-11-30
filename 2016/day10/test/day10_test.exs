defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example(), [2, 5]) == 2
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == 157
  end

  test "part 2 with example" do
    assert Day10.part2(example()) == 2 * 3 * 5
  end

  test "part 2 with my input data" do
    assert Day10.part2(input()) == 1085
  end

  defp example() do
    """
    value 5 goes to bot 2
    bot 2 gives low to bot 1 and high to bot 0
    value 3 goes to bot 1
    bot 1 gives low to output 1 and high to bot 0
    bot 0 gives low to output 2 and high to output 0
    value 2 goes to bot 2
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
