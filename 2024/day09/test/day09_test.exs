defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example()) == 1928
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 6259790630969
  end

  test "part 2 with example" do
    assert Day09.part2(example()) == 2858
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 6289564433984
  end

  defp example() do
    """
    2333133121414131402
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
