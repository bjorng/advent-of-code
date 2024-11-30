defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "test part 1 with examples" do
    assert Day13.part1(example()) == 24
  end

  test "test part 1 with my input data" do
    assert Day13.part1(input()) == 1612
  end

  test "test part 2 with examples" do
    assert Day13.part2(example()) == 10
  end

  test "test part 2 with my input data" do
    assert Day13.part2(input()) == 3907994
  end

  defp example() do
    """
    0: 3
    1: 2
    4: 4
    6: 4
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.stream!("input.txt")
    |> Enum.map(&String.trim/1)
  end
end
