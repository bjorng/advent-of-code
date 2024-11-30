defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with example" do
    assert Day20.part1(example()) == 3
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 3466
  end

  test "part 2 with example" do
    assert Day20.part2(example()) == 1623178306
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 9995532008348
  end

  defp example() do
    """
    1
    2
    -3
    3
    -2
    0
    4
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
