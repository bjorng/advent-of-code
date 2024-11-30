defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1(example()) == 24000
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 71300
  end

  test "part 2 with example" do
    assert Day01.part2(example()) == 45000
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 209691
  end

  defp example() do
    """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """
    |> String.split("\n")
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n")
  end
end
