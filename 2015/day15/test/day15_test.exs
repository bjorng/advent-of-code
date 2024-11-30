defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part 1 with example" do
    assert Day15.part1(example()) == 62842880
  end

  test "part 1 with my input data" do
    assert Day15.part1(input()) == 21367368
  end

  test "part 2 with example" do
    assert Day15.part2(example()) == 57600000
  end

  test "part 2 with my input data" do
    assert Day15.part2(input()) == 1766400
  end

  defp example() do
    """
    Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
    Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
