defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 2
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 490
  end

  test "part 2 with example" do
    assert Day02.part2(example()) == 4
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 536
  end

  defp example() do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
