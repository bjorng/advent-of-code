defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example()) == 50
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 4752484112
  end

  test "part 2 with example" do
    assert Day09.part2(example()) == 24
  end

  test "part 2 with example 2" do
    assert Day09.part2(example2()) == 33
  end

  test "part 2 with example 3" do
    assert Day09.part2(example3()) == 51
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 1465767840
  end

  defp example() do
    """
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    1,1
    3,1
    3,8
    7,8
    7,1
    9,1
    9,11
    1,11
    """
    |> String.split("\n", trim: true)
  end

  defp example3() do
    """
    1,1
    3,1
    3,8
    7,8
    7,1
    14,1
    14,3
    12,3
    12,5
    14,5
    14,9
    17,9
    17,2
    20,2
    20,11
    1,11
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
