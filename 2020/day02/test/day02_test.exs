defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 2
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 645
  end

  test "part 2 with example 2" do
    assert Day02.part2(example()) == 1
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 737
  end

  defp example() do
    """
    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
