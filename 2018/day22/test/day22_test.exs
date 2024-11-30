defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part one, examples" do
    assert Day22.part1(example1()) == 114
  end

  test "part one, real data" do
    assert Day22.part1(input()) == 5622
  end

  test "part two, example" do
    assert Day22.part2(example1()) == 45
  end

  test "part two real data" do
    assert Day22.part2(input()) == 1089
  end

  defp example1 do
    ["depth: 510", "target: 10,10"]
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
