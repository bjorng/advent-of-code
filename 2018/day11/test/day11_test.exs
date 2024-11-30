defmodule Day11Test do
  use ExUnit.Case
  @moduletag timeout: 600_000_000
  doctest Day11

  test "part one, real input" do
    assert Day11.part1(input()) == "20,51"
  end

  test "part two, real input" do
    assert Day11.part2(input()) == "230,272,17"
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
    |> String.to_integer
  end
end
