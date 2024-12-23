defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with example" do
    assert Day20.part1(example(), 1) == 44
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 1343
  end

  test "part 2 with example" do
    assert Day20.part2(example(), 50) == 285
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 982891
  end

  defp example() do
    """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
