defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with example" do
    assert Day19.part1(5) == 3
  end

  test "part 1 with my input data" do
    assert Day19.part1(input()) == 1834903
  end

  test "part 2 with example" do
    assert Day19.part2(5) == 2
    assert Day19.part2(6) == 3
  end

  test "part 2 with my input data" do
    assert Day19.part2(input()) == 1420280
  end

  defp input(), do: 3014603
end
