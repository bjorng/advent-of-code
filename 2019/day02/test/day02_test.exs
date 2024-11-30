defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "test part 1 with my input" do
    assert Day02.part1(input()) == 3224742
  end
  test "test part 2 with my input" do
    assert Day02.part2(input()) == 7960
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
