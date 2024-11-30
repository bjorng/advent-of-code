defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example()) == 288
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == 393120
  end

  test "part 2 with example" do
    assert Day06.part2(example()) == 71503
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == 36872656
  end

  defp example() do
    """
    Time:      7  15   30
    Distance:  9  40  200
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
