defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example()) == 605
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 207
  end

  test "part 2 with example" do
    assert Day09.part2(example()) == 982
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 804
  end

  defp example() do
    """
    London to Dublin = 464
    London to Belfast = 518
    Dublin to Belfast = 141
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
