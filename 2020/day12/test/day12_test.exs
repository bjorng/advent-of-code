defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(example()) == 25
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 420
  end

  test "part 2 with example" do
    assert Day12.part2(example()) == 286
  end

  test "part 2 with my input data" do
    assert Day12.part2(input()) == 42073
  end

  defp example() do
    """
    F10
    N3
    F7
    R90
    F11
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
