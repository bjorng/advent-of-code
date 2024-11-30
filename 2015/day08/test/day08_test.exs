defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "part 1 with example" do
    assert Day08.part1(example()) == 12
  end

  test "part 1 with my input data" do
    assert Day08.part1(input()) == 1350
  end

  test "part 2 with example" do
    assert Day08.part2(example()) == 19
  end

  test "part 2 with my input data" do
    assert Day08.part2(input()) == 2085
  end

  defp example() do
    File.read!("example_input.txt")
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
