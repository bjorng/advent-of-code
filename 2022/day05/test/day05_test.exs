defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == "CMZ"
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == "FRDSQRRCD"
  end

  test "part 2 with example" do
    assert Day05.part2(example()) == "MCD"
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == "HRFTQVWNN"
  end

  defp example() do
    """
        [D]    
    [N] [C]    
    [Z] [M] [P]
     1   2   3 

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
