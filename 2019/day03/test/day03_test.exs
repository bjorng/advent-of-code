defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "test part 1 with examples" do
    assert Day03.part1(["R8,U5,L5,D3","U7,R6,D4,L4"]) == 6
    assert Day03.part1(example1()) == 159
    assert Day03.part1(example2()) == 135
  end

  test "test part 1 with my input" do
    assert Day03.part1(input()) == 1337
  end

  test "test part 2 with examples" do
    assert Day03.part2(["R8,U5,L5,D3","U7,R6,D4,L4"]) == 30
    assert Day03.part2(example1()) == 610
    assert Day03.part2(example2()) == 410
  end

  test "test part 2 with my input" do
    assert Day03.part2(input()) == 65356
  end

  defp example1() do
    ["R75,D30,R83,U83,L12,D49,R71,U7,L72",
     "U62,R66,U55,R34,D71,R55,D58,R83"]
  end

  defp example2() do
    ["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
     "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"]
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
  end
end
