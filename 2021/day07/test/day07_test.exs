defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 37
  end

  test "part 1 with my input data" do
    assert Day07.part1(input()) == 325528
  end

  test "part 2 with example" do
    assert Day07.part2(example()) == 168
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 85015836
  end

  defp example() do
    """
    16,1,2,0,4,2,7,1,2,14
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
