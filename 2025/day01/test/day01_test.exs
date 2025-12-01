defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1(example()) == 3
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 1154
  end

  test "part 2 with example" do
    assert Day01.part2(example()) == 6
    assert Day01.part2(example2()) == 6 + 10 + 9
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 6819
  end

  defp example() do
    """
    L68
    L30
    R48
    L5
    R60
    L55
    L1
    L99
    R14
    L82
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    L168
    L130
    R148
    L105
    R160
    L155
    L101
    L199
    R114
    L182
    L900
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
