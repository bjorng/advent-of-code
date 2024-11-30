defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "test part 1 with example" do
    assert Day14.part1(example()) == 8108
  end

  test "test part 1 with my input" do
    assert Day14.part1(input()) == 8190
  end

  test "test part 2 with example" do
    assert Day14.part2(example()) == 1242
  end

  test "test part 2 with my input" do
    assert Day14.part2(input()) == 1134
  end

  defp example() do
    "flqrgnkx"
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
