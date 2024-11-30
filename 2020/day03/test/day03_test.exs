defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(example()) == 7
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 216
  end

  test "part 2 with example" do
    assert Day03.part2(example()) == 336
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 6708199680
  end

  defp example() do
    """
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
