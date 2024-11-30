defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with example" do
    assert Day16.part1(example()) == 1651
  end

  test "part 1 with my input data" do
    assert Day16.part1(input()) == 1584
  end

  test "part 2 with example" do
    assert Day16.part2(example()) == 1707
  end

  test "part 2 with my input data" do
    assert Day16.part2(input()) == 2052
  end

  defp example() do
    """
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
