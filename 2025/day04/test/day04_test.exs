defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "part 1 with example" do
    assert Day04.part1(example()) == 13
  end

  test "part 1 with my input data" do
    assert Day04.part1(input()) == 1393
  end

  test "part 2 with example" do
    assert Day04.part2(example()) == 43
  end

  test "part 2 with my input data" do
    assert Day04.part2(input()) == 8643
  end

  defp example() do
    """
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@.
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
