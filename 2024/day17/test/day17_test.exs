defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with example" do
    assert Day17.part1(example()) == "4,6,3,5,6,3,5,2,1,0"
  end

  test "part 1 with my input data" do
    assert Day17.part1(input()) == "1,6,3,6,5,6,5,1,7"
  end

  test "part 2 with example" do
    assert Day17.part2(example2()) == 117440
  end

  test "part 2 with my input data" do
    assert Day17.part2(input()) == 247839653009594
  end

  defp example() do
    """
    Register A: 729
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0
    """
  end

  defp example2() do
    """
    Register A: 2024
    Register B: 0
    Register C: 0

    Program: 0,3,5,4,3,0
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
