defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with example" do
    assert Day11.part1(example()) == 374
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == 9627977
  end

  test "part 2 with example" do
    assert Day11.part2(example(), 10) == 1030
    assert Day11.part2(example(), 100) == 8410
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == 644248339497
  end

  defp example() do
    """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
