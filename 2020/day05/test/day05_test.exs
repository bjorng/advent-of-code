defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with my input data" do
    assert Day05.part1(input()) == 919
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == 642
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
