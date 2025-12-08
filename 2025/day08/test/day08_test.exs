defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "part 1 with example" do
    assert Day08.part1(example(), 10) == 40
  end

  test "part 1 with my input data" do
    assert Day08.part1(input(), 1000) == 54180
  end

  test "part 2 with example" do
    assert Day08.part2(example()) == 25272
  end

  test "part 2 with my input data" do
    assert Day08.part2(input()) == 25325968
  end

  defp example() do
    """
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
