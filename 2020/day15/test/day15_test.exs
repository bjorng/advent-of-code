defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part 1 with example" do
    assert Day15.part1("0,3,6") == 436
    assert Day15.part1("2,1,3") == 10
    assert Day15.part1("1,2,3") == 27
  end

  test "part 1 with my input data" do
    assert Day15.part1(input()) == 492
  end

  test "part 2 with example 2" do
    assert Day15.part2("0,3,6") == 175594
  end

  test "part 2 with my input data" do
    assert Day15.part2(input()) == 63644
  end

  defp input() do
    "1,20,8,12,0,14"
  end
end
