defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "part 1 with example" do
    assert Day08.part1(example()) == 14
  end

  test "part 1 with my input data" do
    assert Day08.part1(input()) == 259
  end

  test "part 2 with example" do
    assert Day08.part2(example()) == 34
  end

  test "part 2 with my input data" do
    assert Day08.part2(input()) == 927
  end

  defp example() do
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
