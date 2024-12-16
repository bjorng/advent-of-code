defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with example" do
    assert Day19.part1(example()) == 6
  end

  test "part 1 with my input data" do
    assert Day19.part1(input()) == 311
  end

  test "part 2 with example" do
    assert Day19.part2(example()) == 16
  end

  test "part 2 with my input data" do
    assert Day19.part2(input()) == 616234236468263
  end

  defp example() do
    """
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
