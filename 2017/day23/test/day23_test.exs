defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with my input" do
    assert Day23.part1(input()) == 8281
  end

  test "part 2 with my input" do
    assert Day23.part2(input()) == 911
  end

  defp input do
    File.read!('input.txt')
    |> String.split("\n", trim: true)
  end
end
