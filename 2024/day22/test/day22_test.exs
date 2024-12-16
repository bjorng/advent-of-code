defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with example" do
    assert Day22.part1(example()) == 37327623
  end

  test "part 1 with my input data" do
    assert Day22.part1(input()) == 19822877190
  end

  test "part 2 with example" do
    assert Day22.part2(example2()) == 23
  end

  test "part 2 with my input data" do
    assert Day22.part2(input()) == 2277
  end

  defp example() do
    """
    1
    10
    100
    2024
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    1
    2
    3
    2024
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
