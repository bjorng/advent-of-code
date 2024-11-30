defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with example" do
    assert Day19.part1(example1()) == 4
    assert Day19.part1(example2()) == 7
  end

  test "part 1 with my input data" do
    assert Day19.part1(input()) == 535
  end

  test "part 2 with my input data" do
    assert Day19.part2(input()) == 212
  end

  defp example1() do
    """
    H => HO
    H => OH
    O => HH

    HOH
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    H => HO
    H => OH
    O => HH

    HOHOHO
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
