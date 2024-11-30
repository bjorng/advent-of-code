defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with example" do
    assert Day17.part1(example()) == 102
  end

  test "part 1 with my input data" do
    assert Day17.part1(input()) == 1099
  end

  test "part 2 with example" do
    assert Day17.part2(example()) == 94
    assert Day17.part2(example2()) == 71
  end

  test "part 2 with my input data" do
    assert Day17.part2(input()) == 1266
  end

  defp example() do
    """
    2413432311323
    3215453535623
    3255245654254
    3446585845452
    4546657867536
    1438598798454
    4457876987766
    3637877979653
    4654967986887
    4564679986453
    1224686865563
    2546548887735
    4322674655533
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    111111111111
    999999999991
    999999999991
    999999999991
    999999999991
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
