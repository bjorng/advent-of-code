defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with example" do
    assert Day22.part1(example()) == 5
  end

  test "part 1 with my input data" do
    assert Day22.part1(input()) == 471
  end

  test "part 2 with example" do
    assert Day22.part2(example()) == 7
  end

  test "part 2 with my input data" do
    assert Day22.part2(input()) == 68525
  end

  defp example() do
    """
    1,0,1~1,2,1
    0,0,2~2,0,2
    0,2,3~2,2,3
    0,0,4~0,2,4
    2,0,5~2,2,5
    0,1,6~2,1,6
    1,1,8~1,1,9
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
