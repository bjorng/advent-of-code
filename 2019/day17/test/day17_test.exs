defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with my input" do
    assert Day17.part1(input()) == 7280
  end

  test "part 2 with my input" do
    assert Day17.part2(input()) == 1045393
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
