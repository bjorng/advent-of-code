defmodule Day16Test do
  use ExUnit.Case
  doctest Machine

  test "part one, example" do
    assert Day16.part1(example_part1()) == 1
  end

  test "part one, real data" do
    assert Day16.part1(input()) == 677
  end

  test "part two, real data" do
    assert Day16.part2(input()) == 540
  end

  defp example_part1() do
  """
  Before: [3, 2, 1, 1]
  9 2 1 2
  After:  [3, 2, 2, 1]



  0 0 0 0
  """
  end

  defp input() do
    File.read!("input.txt")
  end

end
