defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "part 1 with example" do
    assert Day08.part1(example()) == 21
  end

  test "part 1 with my input data" do
    assert Day08.part1(input()) == 1805
  end

  test "part 2 with example" do
    assert Day08.part2(example()) == 8
  end

  test "part 2 with my input data" do
    assert Day08.part2(input()) == 444528
  end

  defp example() do
    """
    30373
    25512
    65332
    33549
    35390
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
