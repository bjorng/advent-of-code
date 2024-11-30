defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example(), 5) == 127
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 18272118
  end

  test "part 2 with example" do
    assert Day09.part2(example(), 5) == 62
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 2186361
  end

  defp example() do
    """
    35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
