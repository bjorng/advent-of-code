defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "test part 1 with my input data" do
    assert Day04.part1(input()) == 337
  end

  test "test part 2 with examples" do
    assert Day04.part2(["abcde fghij"]) == 1
    assert Day04.part2(["abcde xyz ecdab"]) == 0
  end

  test "test part 2 with my input data" do
    assert Day04.part2(input()) == 231
  end

  defp input() do
    File.stream!("input.txt")
  end
end
