defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part 1 with example" do
    assert Day25.part1(example()) == 58
  end

  test "part 1 with my input data" do
    assert Day25.part1(input()) == 374
  end

  defp example() do
    """
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
