defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part 1 with example" do
    assert Day15.part1(example()) == 5
  end

  test "part 1 with my input data" do
    assert Day15.part1(input()) == 16824
  end

  test "part 2 with example" do
    assert Day15.part2(example()) == 85
  end

  test "part 2 with my input data" do
    assert Day15.part2(input()) == 3543984
  end

  defp example() do
    """
    Disc #1 has 5 positions; at time=0, it is at position 4.
    Disc #2 has 2 positions; at time=0, it is at position 1.
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
