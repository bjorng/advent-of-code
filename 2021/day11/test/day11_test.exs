defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with example" do
    assert Day11.part1(example(), 10) == 204
    assert Day11.part1(example()) == 1656
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == 1679
  end

  test "part 2 with example" do
    assert Day11.part2(example()) == 195
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == 519
  end

  defp example() do
    """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
