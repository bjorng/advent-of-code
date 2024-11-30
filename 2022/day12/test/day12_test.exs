defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(example()) == 31
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 394
  end

  test "part 2 with example" do
    assert Day12.part2(example()) == 29
  end

  test "part 2 with my input data" do
    assert Day12.part2(input()) == 388
  end

  defp example() do
    """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
