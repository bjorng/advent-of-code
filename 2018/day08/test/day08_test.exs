defmodule Day08Test do
  use ExUnit.Case

  test "part one example" do
    assert Day08.part1(data()) == 138
  end

  test "part one real data" do
    assert Day08.part1(input()) == 41926
  end

  test "part two example" do
    assert Day08.part2(data()) == 66
  end

  test "part two real data" do
    assert Day08.part2(input()) == 24262
  end

  defp data() do
  """
  2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
  """
  |> String.trim
  |> String.split(" ")
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split(" ")
  end

end
