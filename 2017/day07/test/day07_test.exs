defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "test part 1 with examples" do
    assert Day07.part1(example1()) == "tknk"
  end

  test "test part 1 with my input data" do
    assert Day07.part1(input()) == "dtacyn"
  end

  test "test part 2 with examples" do
    assert Day07.part2(example1()) == 60
  end

  test "test part 2 with my input data" do
    assert Day07.part2(input()) == 521
  end

  defp example1() do
    """
    pbga (66)
    xhth (57)
    ebii (61)
    havc (66)
    ktlj (57)
    fwft (72) -> ktlj, cntj, xhth
    qoyq (66)
    padx (45) -> pbga, havc, qoyq
    tknk (41) -> ugml, padx, fwft
    jptl (61)
    ugml (68) -> gyxo, ebii, jptl
    gyxo (61)
    cntj (57)
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
  end
end
