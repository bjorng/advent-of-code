defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with example" do
    assert Day20.part1(example()) == 0
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 157
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 499
  end

  defp example() do
    """
    p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>
    p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
