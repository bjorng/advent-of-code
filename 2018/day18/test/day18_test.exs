defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part one, example" do
    assert Day18.part1(example1()) == {37, 31, 1147}
  end

  test "part one, real data" do
    assert Day18.part1(input()) == {937, 628, 588436}
  end

  test "part two real data" do
    assert Day18.part2(input()) == {590, 331, 195290}
  end

  defp example1() do
    """
    .#.#...|#.
    .....#|##|
    .|..|...#.
    ..|#.....#
    #.#|||#|#|
    ...#.||...
    .|....|...
    ||...#|.#|
    |.||||..|.
    ...#.|..|.
    """
    |> String.trim
    |> String.split("\n")
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
