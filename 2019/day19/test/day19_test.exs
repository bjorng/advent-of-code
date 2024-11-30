defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with my input" do
    assert Day19.part1(input()) == 171
  end

  test "part 2 with my input" do
    assert Day19.part2(input(), 100) == 9741242
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
