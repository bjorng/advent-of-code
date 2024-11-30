defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == example_output()
    assert Day07.part1(Enum.shuffle(example())) == example_output()
  end

  test "part 1 with my input data" do
    assert Day07.part1(input())[:a] == 956
  end

  test "part 2 with my input data" do
    assert Day07.part2(input())[:a] == 40149
  end

  defp example() do
    """
    123 -> x
    456 -> y
    x AND y -> d
    x OR y -> e
    x LSHIFT 2 -> f
    y RSHIFT 2 -> g
    NOT x -> h
    NOT y -> i
    """
    |> String.split("\n", trim: true)
  end

  defp example_output() do
    %{d: 72,
      e: 507,
      f: 492,
      g: 114,
      h: 65412,
      i: 65079,
      x: 123,
      y: 456}
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
