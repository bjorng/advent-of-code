defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with example" do
    assert Day23.part1(example()) == 12521
  end

  test "part 1 with my input data" do
    assert Day23.part1(input()) == 10526
  end

  test "part 2 with example" do
    assert Day23.part2(example()) == 44169
  end

  test "part 2 with my input data" do
    assert Day23.part2(input()) == 41284
  end

  defp example() do
    """
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
