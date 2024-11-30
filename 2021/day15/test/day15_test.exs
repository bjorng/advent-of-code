defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part 1 with example" do
    assert Day15.part1(example()) == 40
  end

  test "part 1 with my input data" do
    assert Day15.part1(input()) == 562
  end

  test "part 2 with example" do
    assert Day15.part2(example()) == 315
  end

  test "part 2 with my input data" do
    assert Day15.part2(input()) == 2874
  end

  defp example() do
    """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
