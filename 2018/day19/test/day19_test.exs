defmodule Day19Test do
  use ExUnit.Case
  doctest Machine

  test "part one, example" do
    assert Day19.part1(example1()) == {6, 5, 6, 0, 0, 9}
  end

  test "part one, real data" do
    assert Day19.part1(input()) == {1302, 1026, 1026, 1025, 1, 256}
  end

  test "part two real data" do
    assert Day19.part2(input()) == {13083798, 10551426, 10551426, 10551425, 1, 256}
  end

  defp example1() do
    """
    #ip 0
    seti 5 0 1
    seti 6 0 2
    addi 0 1 0
    addr 1 2 3
    setr 1 0 0
    seti 8 0 4
    seti 9 0 5
    """
    |> String.trim
    |> String.split("\n")
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
