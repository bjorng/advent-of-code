defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == 35
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == 600279879
  end

  test "part 2 with example" do
    assert Day05.part2(example()) == 46
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == 20191102
  end

  defp example() do
    """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
