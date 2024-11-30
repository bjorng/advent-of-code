defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example(), 18) == 26
    assert Day06.part1(example(), 80) == 5934
  end

  test "part 1 with my input data" do
    assert Day06.part1(input(), 80) == 380758
  end

  test "part 2 with example" do
    assert Day06.part2(example(), 256) == 26984457539
  end

  test "part 2 with my input data" do
    assert Day06.part2(input(), 256) == 1710623015163
  end

  defp example() do
    """
    3,4,3,1,2
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
