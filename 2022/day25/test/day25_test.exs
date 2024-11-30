defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part 1 with example" do
    assert Day25.part1(example()) == "2=-1=0"
  end

  test "part 1 with my input data" do
    assert Day25.part1(input()) == "2-212-2---=00-1--102"
  end

  defp example() do
    """
    1=-0-2
    12111
    2=0=
    21
    2=01
    111
    20012
    112
    1=-1=
    1-12
    12
    1=
    122
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
