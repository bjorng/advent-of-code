defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part 1 with example" do
    assert Day15.part1(example()) == 1320
  end

  test "part 1 with my input data" do
    assert Day15.part1(input()) == 506891
  end

  test "part 2 with example" do
    assert Day15.part2(example()) == 145
  end

  test "part 2 with my input data" do
    assert Day15.part2(input()) == 230462
  end

  defp example() do
    """
    rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
