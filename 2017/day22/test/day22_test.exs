defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with example" do
    assert Day22.part1(example()) == 5587
  end

  test "part 1 with my input data" do
    assert Day22.part1(input()) == 5348
  end

  test "part 2 with example" do
    assert Day22.part2(example(), 100) == 26
    assert Day22.part2(example()) == 2511944
  end

  test "part 2 with my input data" do
    assert Day22.part2(input()) == 2512225
  end

  defp example() do
    """
    ..#
    #..
    ...
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
