defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example()) == nil
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == nil
  end

  test "part 2 with example" do
#    assert Day10.part2(example()) == nil
  end

  test "part 2 with my input data" do
#    assert Day10.part2(input()) == nil
  end

  defp example() do
    """

    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
