defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "part 1 with example" do
    assert Day04.part1("abcdef") == 609043
    assert Day04.part1("pqrstuv") == 1048970
  end

  test "part 1 with my input data" do
    assert Day04.part1(input()) == 117946
  end

  test "part 2 with my input data" do
    assert Day04.part2(input()) == 3938038
  end

  defp input(), do: "ckczppom"
end
