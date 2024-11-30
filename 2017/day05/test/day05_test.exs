defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "test part 1 with my input data" do
    assert Day05.part1(input()) == 343364
  end

  test "test part 1 with examples" do
    assert Day05.part1(example1()) == 5
  end

  test "test part 2 with examples" do
    assert Day05.part2(example1()) == 10
  end

  test "test part 2 with my input data" do
    assert Day05.part2(input()) == 25071947
  end

  defp example1() do
    """
    0
    3
    0
    1
    -3
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.stream!("input.txt")
  end
end
