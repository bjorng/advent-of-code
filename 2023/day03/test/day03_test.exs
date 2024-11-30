defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(example()) == 4361
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 553825
  end

  test "part 2 with example" do
    assert Day03.part2(example()) == 467835
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 93994191
  end

  defp example() do
    """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
