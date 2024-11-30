defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with my input" do
    assert Day23.part1(input()) == 21160
  end

  test "part 2 with my input" do
    # 14334 is too high
    # 14329 is too high
    assert Day23.part2(input()) == 14327
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end

end
