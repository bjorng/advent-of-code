defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "test part 1 with examples" do
    assert Day12.part1(example()) == 6
  end

  test "test part 1 with my input data" do
    assert Day12.part1(input()) == 130
  end

  test "test part 2 with my input data" do
    assert Day12.part2(input()) == 189
  end

  defp example() do
    """
    0 <-> 2
    1 <-> 1
    2 <-> 0, 3, 4
    3 <-> 2, 4
    4 <-> 2, 3, 6
    5 <-> 6
    6 <-> 4, 5
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.stream!("input.txt")
    |> Enum.map(&String.trim/1)
  end
end
