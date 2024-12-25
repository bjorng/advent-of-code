defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part 1 with example" do
    assert Day25.part1(example()) == 3
  end

  test "part 1 with my input data" do
    assert Day25.part1(input()) == 3608
  end

  defp example() do
    """
    #####
    .####
    .####
    .####
    .#.#.
    .#...
    .....

    #####
    ##.##
    .#.##
    ...##
    ...#.
    ...#.
    .....

    .....
    #....
    #....
    #...#
    #.#.#
    #.###
    #####

    .....
    .....
    #.#..
    ###..
    ###.#
    ###.#
    #####

    .....
    .....
    .....
    #....
    #.#..
    #.#.#
    #####
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
