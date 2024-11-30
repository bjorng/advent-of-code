defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 150
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 2070300
  end

  test "part 2 with example" do
    assert Day02.part2(example()) == 900
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 2078985210
  end

  defp example() do
    """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
