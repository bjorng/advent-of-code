defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 481
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n\n", trim: true)
  end
end
