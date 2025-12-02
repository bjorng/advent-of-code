defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 1227775554
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 18893502033
  end

  test "part 2 with example" do
    assert Day02.part2(example()) == 4174379265
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 26202168557
  end

  defp example() do
    """
    11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
