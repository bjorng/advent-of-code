defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "test part 1 with examples" do
    assert Day08.part1(example1()) == 1
  end

  test "test part 1 with my input data" do
    assert Day08.part1(input()) == 5849
  end

  test "test part 2 with examples" do
    assert Day08.part2(example1()) == 10
  end

  test "test part 2 with my input data" do
    assert Day08.part2(input()) == 6702
  end

  defp example1() do
    """
    b inc 5 if a > 1
    a inc 1 if b < 5
    c dec -10 if a >= 1
    c inc -20 if c == 10
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
  end
end
