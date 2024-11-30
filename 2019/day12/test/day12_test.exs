defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "test part 1 with examples" do
    assert Day12.part1(example1(), 10) == 179
    assert Day12.part1(example2(), 100) == 1940
  end

  test "test part 1 with my input" do
    assert Day12.part1(input(), 1000) == 6220
  end

  test "test part 2 with examples" do
    assert Day12.part2(example1()) == 2772
    assert Day12.part2(example2()) == 4686774924
  end

  test "test part 2 with my input" do
    assert Day12.part2(input()) == 548525804273976
  end

  defp example1() do
    ["<x=-1, y=0, z=2>",
     "<x=2, y=-10, z=-7>",
     "<x=4, y=-8, z=8>",
     "<x=3, y=5, z=-1>"]
  end

  defp example2() do
    ["<x=-8, y=-10, z=0>",
     "<x=5, y=5, z=10>",
     "<x=2, y=-7, z=3>",
     "<x=9, y=-8, z=-3>"]
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
  end
end
