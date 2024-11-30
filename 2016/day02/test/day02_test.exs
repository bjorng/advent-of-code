defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 1985
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 48584
  end

  test "part 2 with example" do
    assert Day02.part2(example()) == "5DB3"
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == "563B6"
  end

  defp example() do
    """
    ULL
    RRDDD
    LURDL
    UUUUD
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
