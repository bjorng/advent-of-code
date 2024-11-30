defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "test both parts with examples" do
    assert Day06.solve(example1()) == {5, 4}
  end

  test "test both parts with my input data" do
    assert Day06.solve(input()) == {12841, 8038}
  end

  defp example1() do
    "0 2 7 0"
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
