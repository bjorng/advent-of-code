defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with example" do
    assert Day23.part1(example())[:a] == 2
  end

  test "part 1 with my input data" do
    assert Day23.part1(input())[:b] == 184
  end

  test "part 2 with my input data" do
    assert Day23.part2(input())[:b] == 231
  end

  defp example() do
    """
    inc a
    jio a, +2
    tpl a
    inc a
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
