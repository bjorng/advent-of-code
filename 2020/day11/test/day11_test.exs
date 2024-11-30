defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with example" do
    assert Day11.part1(example()) == 37
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == 2406
  end

  test "part 2 with example" do
    assert Day11.part2(example()) == 26
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == 2149
  end

  defp example() do
    """
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
