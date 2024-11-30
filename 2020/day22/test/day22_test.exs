defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with example" do
    assert Day22.part1(example()) == 306
  end

  test "part 1 with my input data" do
    assert Day22.part1(input()) == 31455
  end

  test "part 2 with example" do
    assert Day22.part2(example()) == 291
  end

  test "part 2 with my input data" do
    assert Day22.part2(input()) == 32528
  end

  defp example() do
    """
    Player 1:
    9
    2
    6
    3
    1

    Player 2:
    5
    8
    4
    7
    10
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
