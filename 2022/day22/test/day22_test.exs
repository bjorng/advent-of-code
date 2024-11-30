defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with example" do
    assert Day22.part1(example()) == 6032
  end

  test "part 1 with my input data" do
    assert Day22.part1(input()) == 11464
  end

  test "part 2 with example" do
    assert Day22.part2(example()) == 5031
  end

  test "part 2 with my input data" do
    assert Day22.part2(input()) == 197122
  end

  defp example() do
    """
            ...#
            .#..
            #...
            ....
    ...#.......#
    ........#...
    ..#....#....
    ..........#.
            ...#....
            .....#..
            .#......
            ......#.

    10R5L5R10L4R5L5
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
