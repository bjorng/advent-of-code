defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
    assert Day14.part1(example()) == 165
  end

  test "part 1 with my input data" do
    assert Day14.part1(input()) == 6386593869035
  end

  test "part 2 with example 2" do
    assert Day14.part2(example2()) == 208
  end

  test "part 2 with my input data" do
    assert Day14.part2(input()) == 4288986482164
  end

  defp example() do
    """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end

end
