defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part 1 with example" do
    assert Day13.part1(example()) == 405
    assert Day13.part1(example2()) == 3
    assert Day13.part1(example3()) == 14
  end

  test "part 1 with my input data" do
    assert Day13.part1(input()) == 34772
  end

  test "part 2 with example" do
    assert Day13.part2(example()) == 400
  end

  test "part 2 with my input data" do
    assert Day13.part2(input()) == 35554
  end

  defp example() do
    """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """
    |> String.split("\n\n", trim: true)
  end

  defp example2() do
    """
    .#..#.##.
    ##..####.
    .#..#..#.
    ..##....#
    .#..#..#.
    .#..#.###
    ........#
    ......#.#
    ##..##.##
    ##..##.#.
    ##..##...
    ##..##.##
    ......#.#
    ........#
    .#..#.###
    """
    |> String.split("\n\n", trim: true)
  end

  defp example3() do
    """
    ....###...#..##
    #..####..##..##
    .###..###.#.###
    ...####...#####
    #..#..#..##..##
    #.##..##.#.....
    #........#.##..
    """
    |> String.split("\n\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n\n", trim: true)
  end
end
