defmodule Day21Test do
  use ExUnit.Case
  doctest Machine

  test "part one: decompile" do
    assert Day21.decompile_program(input()) == :ok
  end

  test "part one: run" do
    assert Day21.part1(input(), 12446070) == 12446070
  end

  test "part two" do
    assert Day21.part2(input()) == 13928239
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
