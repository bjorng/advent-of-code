defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with example" do
    assert Day16.part1("10000", 20) == "01100"
  end

  test "part 1 with my input data" do
    assert Day16.part1(input()) == "11100111011101111"
  end

  test "part 2 with my input data" do
    assert Day16.part2(input()) == "10001110010000110"
  end

  defp input(), do: "01110110101001000"
end
