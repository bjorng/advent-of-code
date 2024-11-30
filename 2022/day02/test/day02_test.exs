defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 15
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 12679
  end

  test "part 2 with example" do
    assert Day02.part2(example()) == 12
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 14470
  end

  defp example() do
    """
    A Y
    B X
    C Z
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
