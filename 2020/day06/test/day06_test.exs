defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

    test "part 1 with example" do
    assert Day06.part1(example()) == 11
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == 6742
  end

  test "part 2 with example 2" do
    assert Day06.part2(example()) == 6
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == 3447
  end

  defp example() do
    """
    abc

    a
    b
    c

    ab
    ac

    a
    a
    a
    a

    b
    """
    |> String.split("\n")
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n")
  end

end
