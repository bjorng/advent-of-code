defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with example" do
    assert Day16.part1(example()) == 71
  end

  test "part 1 with my input data" do
    assert Day16.part1(input()) == 26009
  end

  test "part 2 with my input data" do
    assert Day16.part2(input()) == 589685618167
  end

  defp example() do
    """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
