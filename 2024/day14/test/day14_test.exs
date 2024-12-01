defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1 with example" do
    assert Day14.part1(example(), 100, 11, 7) == 12
  end

  test "part 1 with my input data" do
    assert Day14.part1(input(), 100, 101, 103) == 214400550
  end

  test "part 2 with example" do
#    assert Day14.part2(example(), 100, 11, 7) == nil
  end

  test "part 2 with my input data" do
    assert Day14.part2(input(), 10_000, 101, 103) == 8149
  end

  defp example() do
    """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
