defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "test part 1 with my input" do
    assert Day15.part1(input()) == 404
  end

  test "test part 2 with my input" do
    assert Day15.part2(input()) == 406
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
