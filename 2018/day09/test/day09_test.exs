defmodule Day09Test do
  use ExUnit.Case

  test "part one example" do
    assert Day09.solve(9, 25) == 32
    assert Day09.solve(10, 1618) == 8317
    assert Day09.solve(13, 7999) == 146373
    assert Day09.solve(17, 1104) == 2764
    assert Day09.solve(21, 6111) == 54718
    assert Day09.solve(30, 5807) == 37305
  end

  test "part one, real input" do
    assert Day09.part1(input()) == 439635
  end

  test "part two, real input" do
    assert Day09.part2(input()) == 3562722971
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
