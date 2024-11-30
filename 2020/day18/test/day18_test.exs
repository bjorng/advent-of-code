defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1(["1 + (2 * 3) + (4 * (5 + 6))"]) === 51
    assert Day18.part1(["1 + 2 * 3 + 4 * 5 + 6"]) === 71
    assert Day18.part1(["2 * 3 + (4 * 5)"]) === 26
    assert Day18.part1(["5 + (8 * 3 + 9 + 3 * 4 * 3)"]) === 437
    assert Day18.part1(["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"]) === 12240
    assert Day18.part1(["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"]) === 13632
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 30753705453324
  end

  test "part 2 with example 2" do
    assert Day18.part2(["1 + (2 * 3) + (4 * (5 + 6))"]) === 51
    assert Day18.part2(["1 + 2 * 3 + 4 * 5 + 6"]) === 231
    assert Day18.part2(["2 * 3 + (4 * 5)"]) === 46
    assert Day18.part2(["8 * 3 + 9 + 3 * 4 * 3"]) === 1440
    assert Day18.part2(["(8 * 3 + 9 + 3 * 4 * 3)"]) === 1440
    assert Day18.part2(["(8 * 3 + 9 + 3 * 4 * 3) + 5"]) === 1445
    assert Day18.part2(["5 + (8 * 3 + 9 + 3 * 4 * 3)"]) === 1445
    assert Day18.part2(["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"]) === 669060
    assert Day18.part2(["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"]) === 23340
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == 244817530095503
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
