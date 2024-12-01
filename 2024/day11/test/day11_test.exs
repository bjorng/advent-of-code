defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with example" do
    assert Day11.part1(example(), 6) == 22
    assert Day11.part1(example()) == 55312
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == 220722
  end

  test "part 2 with example" do
    assert Day11.part2(example(), 6) == 22
    assert Day11.part2(example(), 25) == 55312
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == 261952051690787
  end

  defp example() do
    """
    125 17
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
