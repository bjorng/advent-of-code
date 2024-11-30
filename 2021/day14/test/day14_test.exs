defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
    assert Day14.part1(example()) == 1588
  end

  test "part 1 with my input data" do
    assert Day14.part1(input()) == 2509
  end

  test "part 2 with example" do
    assert Day14.part2(example()) == 2188189693529
  end

  test "part 2 with my input data" do
    assert Day14.part2(input()) == 2827627697643
  end

  defp example() do
    #    NNCB
    """
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
