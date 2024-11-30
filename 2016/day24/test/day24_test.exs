defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with example" do
    assert Day24.part1(example()) == 14
  end

  test "part 1 with my input data" do
    assert Day24.part1(input()) == 518
  end

  test "part 2 with example" do
    assert Day24.part2(example()) == 20
  end

  test "part 2 with my input data" do
    assert Day24.part2(input()) == 716
  end

  defp example() do
    """
    ###########
    #0.1.....2#
    #.#######.#
    #4.......3#
    ###########
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
