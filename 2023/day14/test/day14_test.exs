defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
#    assert Day14.part1(example()) == 136
  end

  test "part 1 with my input data" do
#    assert Day14.part1(input()) == 110821
  end

  test "part 2 with example" do
    assert Day14.part2(example()) == 64
  end

  test "part 2 with my input data" do
    assert Day14.part2(input()) == 83516
  end

  defp example() do
    """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
