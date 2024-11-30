defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1("1") == "11"
    assert Day10.part1("11") == "21"
    assert Day10.part1("21") == "1211"
    assert Day10.part1("1211") == "111221"
    assert Day10.part1("111221") == "312211"
    assert Day10.part1("1", 5) == "312211"
  end

  test "part 1 with my input data" do
    assert byte_size(Day10.part1(input(), 40)) == 329356
  end

  test "part 2 with my input data" do
    assert byte_size(Day10.part1(input(), 50)) == 4666278
  end

  defp input() do
    "3113322113"
  end
end
