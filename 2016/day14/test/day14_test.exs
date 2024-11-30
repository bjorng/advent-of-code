defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
    assert Day14.part1("abc") == 22728
  end

  test "part 1 with my input data" do
    assert Day14.part1(input()) == 15168
  end

  test "part 2 with example" do
    assert Day14.part2("abc") == 22551
  end

  test "part 2 with my input data" do
    assert Day14.part2(input()) == 20864
  end

  defp input(), do: "qzyelonm"
end
