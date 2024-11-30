defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with example" do
    assert Day20.part1(example()) == 3
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 22887907
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 109
  end

  defp example() do
    """
    5-8
    0-2
    4-7
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
