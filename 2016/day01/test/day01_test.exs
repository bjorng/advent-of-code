defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1(["R2, L3"]) == 5
    assert Day01.part1(["R2, R2, R2"]) == 2
    assert Day01.part1(["R5, L5, R5, R3"]) == 12
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 287
  end

  test "part 2 with example" do
    assert Day01.part2(["R8, R4, R4, R8"]) == 4
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 133
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
