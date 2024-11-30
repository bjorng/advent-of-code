defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with example" do
    assert Day24.part1(example()) == 18
  end

  test "part 1 with my input data" do
    assert Day24.part1(input()) == 266
  end

  test "part 2 with example" do
    assert Day24.part2(example()) == 54
  end

  test "part 2 with my input data" do
    assert Day24.part2(input()) == 853
  end

  defp example() do
    """
    #.######
    #>>.<^<#
    #.<..<<#
    #>v.><>#
    #<^v^^>#
    ######.#
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
