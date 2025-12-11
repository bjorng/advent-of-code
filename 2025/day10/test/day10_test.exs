defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example()) == 7
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == 498
  end

  test "part 2 with example" do
#    assert Day10.part2(example()) == 33
  end

  test "part 2 with example 2" do
    assert Day10.part2(example2()) == 122
  end

  test "part 2 with my input data" do
#    assert Day10.part2(input()) == nil
  end

  defp example() do
    """
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    [..##...#.] (0,1,2,3,4) (2,3,4,5,6,8) (0,2,3,6,7) (1,2,3,4,5,7,8) (0,3,4,8) (1,2,3,4,5,6,8) (0,4,5,6,7,8) (0,1,3,6,8) (1,3,5,6,7) (0,3,5,7) {78,66,64,114,75,62,62,62,70}
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
