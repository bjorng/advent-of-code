defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "part 1 with example" do
    assert Day08.part1(example()) == 5
  end

  test "part 1 with my input data" do
    assert Day08.part1(input()) == 1262
  end

  test "part 2 with example" do
    assert Day08.part2(example()) == 8
  end

  test "part 2 with my input data" do
    assert Day08.part2(input()) == 1643
  end

  defp example() do
    """
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
