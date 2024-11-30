defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1(example()) == 514579
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 1014624
  end

  test "part 2 with example 2" do
    assert Day01.part2(example()) == 241861950
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 80072256
  end

  defp example() do
    """
    1721
    979
    366
    299
    675
    1456
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
