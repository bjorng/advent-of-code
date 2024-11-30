defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1(example(), 4) == 4
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 1061
  end

  test "part 2 with example" do
    assert Day18.part2(example(), 5) == 17
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == 1006
  end

  defp example() do
    """
    .#.#.#
    ...##.
    #....#
    ..#...
    #.#..#
    ####..
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
