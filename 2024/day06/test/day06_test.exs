defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example()) == 41
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == 4656
  end

  test "part 2 with example" do
    assert Day06.part2(example()) == 6
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == 1575
  end

  defp example() do
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
