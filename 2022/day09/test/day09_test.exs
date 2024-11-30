defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.part1(example()) == 13
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 6067
  end

  test "part 2 with example" do
    assert Day09.part2(example()) == 1
    assert Day09.part2(example2()) == 36
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 2471
  end

  defp example() do
    """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
