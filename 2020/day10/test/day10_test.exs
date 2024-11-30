defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example()) == 7 * 5
    assert Day10.part1(example2()) == 22 * 10
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == 2170
  end

  test "part 2 with example" do
    assert Day10.part2(["1"]) == 1
    assert Day10.part2(["1", "4"]) == 1
    assert Day10.part2(example()) == 8
    assert Day10.part2(example2()) == 19208
  end

  test "part 2 with my input data" do
    assert Day10.part2(input()) == 24803586664192
  end

  defp example() do
    """
    16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
