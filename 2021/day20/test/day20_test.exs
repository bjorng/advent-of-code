defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with example" do
    assert Day20.part1(example()) == 35
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 4928
  end

  test "part 2 with example" do
    assert Day20.part2(example()) == 3351
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 16605
  end

  defp example() do
    """
    ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

    #..#.
    #....
    ##..#
    ..#..
    ..###
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
