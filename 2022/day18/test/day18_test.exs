defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1(example1()) == 10
    assert Day18.part1(example2()) == 64
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 3586
  end

  test "part 2 with example" do
    assert Day18.part2(example0()) == 6
    assert Day18.part2(example1()) == 10
    assert Day18.part2(example2()) == 58
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == 2072
  end

  defp example0() do
    """
    1,1,1
    """
    |> String.split("\n", trim: true)
  end

  defp example1() do
    """
    1,1,1
    2,1,1
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
