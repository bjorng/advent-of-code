defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with example" do
    assert Day17.part1(example(), 25) == 4
  end

  test "part 1 with my input data" do
    assert Day17.part1(input()) == 1638
  end

  test "part 2 with example" do
    assert Day17.part2(example(), 25) == 3
  end

  test "part 2 with my input data" do
    assert Day17.part2(input()) == 17
  end

  defp example() do
    """
    20
    15
    10
    5
    5
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
