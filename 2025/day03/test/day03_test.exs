defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(example()) == 357
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 17085
  end

  test "part 2 with example" do
    assert Day03.part2(example()) == 3121910778619
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 169408143086082
  end

  defp example() do
    """
    987654321111111
    811111111111119
    234234234234278
    818181911112111
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
