defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example()) == 36
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == 472
  end

  test "part 2 with example" do
    assert Day10.part2(example()) == 81
  end

  test "part 2 with my input data" do
    assert Day10.part2(input()) == 969
  end

  defp example() do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
