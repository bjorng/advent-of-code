defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part 1 with my input data" do
    assert Day25.part1(input()) == 19980801
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
