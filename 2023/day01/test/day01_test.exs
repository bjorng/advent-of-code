defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1(example()) == 142
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 55488
  end

  test "part 2 with example" do
    assert Day01.part2(example_part2()) == 281
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 55614
  end

  defp example() do
    """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
    |> String.split("\n", trim: true)
  end

  defp example_part2() do
    """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
