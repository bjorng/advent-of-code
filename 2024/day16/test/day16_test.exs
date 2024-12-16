defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with example" do
    assert Day16.part1(example()) == 7036
    assert Day16.part1(example2()) == 11048
  end

  test "part 1 with my input data" do
    assert Day16.part1(input()) == 109496
  end

  test "part 2 with example" do
    assert Day16.part2(example()) == 45
    assert Day16.part2(example2()) == 64
  end

  test "part 2 with my input data" do
    assert Day16.part2(input()) == 551
  end

  defp example() do
    """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
