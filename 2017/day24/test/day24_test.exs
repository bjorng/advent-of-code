defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with example" do
    assert Day24.part1(example()) == 31
  end

  test "part 1 with my input data" do
    assert Day24.part1(input()) == 1656
  end

  test "part 2 with example" do
    assert Day24.part2(example()) == 19
  end

  test "part 2 with my input data" do
    assert Day24.part2(input()) == 1642
  end

  defp example() do
    """
    0/2
    2/2
    2/3
    3/4
    3/5
    0/1
    10/1
    9/10
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
