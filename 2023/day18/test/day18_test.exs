defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1(example()) == 62
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 50465
  end

  test "part 2 with example" do
    assert Day18.part2(example()) == 952408144115
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == 82712746433310
  end

  defp example() do
    """
    R 6 (#70c710)
    D 5 (#0dc571)
    L 2 (#5713f0)
    D 2 (#d2c081)
    R 2 (#59c680)
    D 2 (#411b91)
    L 5 (#8ceee2)
    U 2 (#caa173)
    L 1 (#1b58a2)
    U 2 (#caa171)
    R 2 (#7807d2)
    U 3 (#a77fa3)
    L 2 (#015232)
    U 2 (#7a21e3)
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
