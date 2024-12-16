defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(example()) == 126384
#    assert Day21.part1(["029A"]) == nil
  end

  test "part 1 with my input data" do
    assert Day21.part1(input()) == 174124
  end

  test "part 2 with my input data" do
    assert Day21.part2(input()) == 216668579770346
  end

  defp example() do
    """
    029A
    980A
    179A
    456A
    379A
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
