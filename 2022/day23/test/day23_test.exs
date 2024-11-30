defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with example" do
    assert Day23.part1(example()) == 110
  end

  test "part 1 with my input data" do
    assert Day23.part1(input()) == 3684
  end

  test "part 2 with example" do
    assert Day23.part2(example()) == 20
  end

  test "part 2 with my input data" do
    assert Day23.part2(input()) == 862
  end

  defp example() do
    """
    ....#..
    ..###.#
    #...#.#
    .#...##
    #.###..
    ##.#.##
    .#..#..
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
