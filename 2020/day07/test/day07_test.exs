defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 4
  end

  test "part 1 with my input data" do
    assert Day07.part1(input()) == 372
  end

  test "part 2 with example" do
    assert Day07.part2(example()) == 32
    assert Day07.part2(example2()) == 126
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 8015
  end

  defp example() do
    """
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    shiny gold bags contain 2 dark red bags.
    dark red bags contain 2 dark orange bags.
    dark orange bags contain 2 dark yellow bags.
    dark yellow bags contain 2 dark green bags.
    dark green bags contain 2 dark blue bags.
    dark blue bags contain 2 dark violet bags.
    dark violet bags contain no other bags.
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
