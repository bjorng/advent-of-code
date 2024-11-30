defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with example" do
    assert Day17.part1(example()) == 3068
  end

  test "part 1 with my input data" do
    assert Day17.part1(input()) == 3224
  end

  test "part 2 with example" do
    assert Day17.part2(example()) == 1514285714288
  end

  test "part 2 with my input data" do
    assert Day17.part2(input()) == 1595988538691
  end

  defp example() do
    """
    >>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
