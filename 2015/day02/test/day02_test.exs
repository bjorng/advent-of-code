defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(["2x3x4"]) == 58
    assert Day02.part1(["1x1x10"]) == 43
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 1606483
  end

  test "part 2 with example" do
    assert Day02.part2(["2x3x4"]) == 34
    assert Day02.part2(["1x1x10"]) == 14
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 3842356
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
