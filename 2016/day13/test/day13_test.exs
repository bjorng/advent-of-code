defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part 1 with example" do
    assert Day13.part1(10, {7, 4}) == 11
  end

  test "part 1 with my input data" do
    assert Day13.part1(input()) == 82
  end

  test "part 2 with example" do
    assert Day13.part2(10, 1) == 3
    assert Day13.part2(10, 2) == 5
    assert Day13.part2(10, 3) == 6
    assert Day13.part2(10, 4) == 9
  end

  test "part 2 with my input data" do
    assert Day13.part2(input()) == 138
  end

  defp input(), do: 1362
end
