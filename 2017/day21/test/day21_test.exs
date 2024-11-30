defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(example(), 2) == 12
    assert Day21.part1(input(), 3) == 30
    assert Day21.part1(input(), 4) == 56
  end

  test "part 1 with my input data" do
    assert Day21.part1(input()) == 139
  end

  test "part 2 with my input data" do
    assert Day21.part2(input()) == 1857134
  end

  defp example() do
    """
    ../.# => ##./#../...
    .#./..#/### => #..#/..../..../#..#
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
