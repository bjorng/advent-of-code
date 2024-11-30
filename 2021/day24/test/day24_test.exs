defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part 1 with my input data" do
    assert Day24.part1(input()) == 51983999947999
  end

  test "part 2 with my input data" do
    assert Day24.part2(input()) == 11211791111365
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
