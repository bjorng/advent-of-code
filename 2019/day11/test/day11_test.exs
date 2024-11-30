defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "test part 1 with examples" do
    assert Day11.test_robot([1,0, 0,0, 1,0, 1,0, 0,1, 1,0, 1,0]) == 6
  end

  test "test part 1 with my input" do
    assert Day11.part1(input()) == 2322
  end

  test "test part 2 with my input" do
    assert Day11.part2(input()) == :ok
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
