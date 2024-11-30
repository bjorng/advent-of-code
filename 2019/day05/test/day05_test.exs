defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "test part 1 with my input" do
    assert Day05.part1(input()) == 3122865
  end

  test "test part 2 with examples" do
    assert Day05.part2(example1(), 0) == 0
    assert Day05.part2(example1(), 1) == 1
    assert Day05.part2(example1(), 42) == 1
    assert Day05.part2(example2(), 0) == 0
    assert Day05.part2(example2(), 1) == 1
    assert Day05.part2(example2(), 42) == 1
    assert Day05.part2(example3(), 7) == 999
    assert Day05.part2(example3(), 8) == 1000
    assert Day05.part2(example3(), 9) == 1001
  end

  test "test part 2 with my input" do
    assert Day05.part2(input(), 5) == 773660
  end

  defp example1() do
    "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
  end

  defp example2() do
    "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
  end

  defp example3() do
    "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
