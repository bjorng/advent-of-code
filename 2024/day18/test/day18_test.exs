defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1(example(), 6, 12) == 22
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 262
  end

  test "part 2 with example" do
    assert Day18.part2(example(), 6, 12) == {6, 1}
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == {22, 20}
  end

  defp example() do
    """
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
