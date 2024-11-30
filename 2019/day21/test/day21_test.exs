defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with my input" do
    assert Day21.part1(input()) == 19355645
  end

  test "part 2 with my input" do
    assert Day21.part2(input()) == 1137899149
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
