defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part one examples" do
    assert Day13.part1(data()) == {7, 3}
    assert Day13.part1(data2()) == {2, 0}
  end

  test "part one real data" do
    assert Day13.part1(input()) == {58, 93}
  end

  test "part two example" do
    assert Day13.part2(data2()) == {6, 4}
  end

  test "part two real data" do
    assert Day13.part2(input()) == {91, 72}
  end

  defp data() do
    File.read!("example")
    |> String.split("\n")
  end

  defp data2() do
    File.read!("example2")
    |> String.split("\n")
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n")
  end

end
