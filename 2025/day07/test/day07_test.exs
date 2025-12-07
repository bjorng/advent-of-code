defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 21
  end

  test "part 1 with my input data" do
    assert Day07.part1(input()) == 1550
  end

  test "part 2 with example" do
    assert Day07.part2(example()) == 40
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 9897897326778
  end

  defp example() do
    """
    .......S.......
    ...............
    .......^.......
    ...............
    ......^.^......
    ...............
    .....^.^.^.....
    ...............
    ....^.^...^....
    ...............
    ...^.^...^.^...
    ...............
    ..^...^.....^..
    ...............
    .^.^.^.^.^...^.
    ...............
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
