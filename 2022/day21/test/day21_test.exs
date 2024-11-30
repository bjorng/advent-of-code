defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(example()) == 152
  end

  test "part 1 with my input data" do
    assert Day21.part1(input()) == 75147370123646
  end

  test "part 2 with example" do
    assert Day21.part2(example()) == 301
  end

  test "part 2 with my input data" do
    assert Day21.part2(input()) == 3423279932937
  end

  defp example() do
    """
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
