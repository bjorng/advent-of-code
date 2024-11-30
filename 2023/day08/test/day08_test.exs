defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "part 1 with example" do
    assert Day08.part1(example()) == 2
    assert Day08.part1(example2()) == 6
  end

  test "part 1 with my input data" do
    assert Day08.part1(input()) == 22357
  end

  test "part 2 with example" do
    assert Day08.part2(example3()) == 6
  end

  test "part 2 with my input data" do
    assert Day08.part2(input()) == 10371555451871
  end

  defp example() do
    """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
    |> String.split("\n", trim: true)
  end

  defp example3() do
    """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
