defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "test part 1 with example" do
    assert Day15.part1(65, 8921) == 588
  end

  test "test part 1 with my input" do
    assert Day15.part1(input()) == 609
  end

  test "test part 2 with example" do
    assert Day15.part2(65, 8921) == 309
  end

  test "test part 2 with my input" do
    assert Day15.part2(input()) == 253
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
