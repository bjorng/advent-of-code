defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
    assert Day14.part1(example(), 1000) == 1120
  end

  test "part 1 with my input data" do
    assert Day14.part1(input()) == 2640
  end

  test "part 2 with example" do
    assert Day14.part2(example(), 1000) == 689
  end

  test "part 2 with my input data" do
    assert Day14.part2(input()) == 1102
  end

  defp example() do
    """
    Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
    Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
