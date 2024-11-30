defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example()) == 114
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 1939607039
  end

  test "part 2 with example" do
    assert Day09.part2(example()) == 2
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 1041
  end

  defp example() do
    """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
