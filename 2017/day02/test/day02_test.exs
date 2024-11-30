defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "test part 1 with examples" do
    assert Day02.part1(example1()) == 18
  end

  test "test part 1 with my input data" do
    assert Day02.part1(input()) == 47623
  end

  test "test part 2 with examples" do
    assert Day02.part2(example2()) == 9
  end

  test "test part 2 with my input data" do
    assert Day02.part2(input()) == 312
  end

  defp example1() do
    """
    5 1 9 5
    7 5 3
    2 4 6 8
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    5 9 2 8
    9 4 7 3
    3 8 6 5
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
