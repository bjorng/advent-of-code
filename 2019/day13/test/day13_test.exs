defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "test part 1 with my input" do
    assert Day13.part1(input()) == 298
  end

  test "test part 2 with my input" do
    assert Day13.part2(input()) == 13956
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
