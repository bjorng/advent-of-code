defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part 1 with example" do
    assert Day13.part1(example()) == 13
  end

  test "part 1 with my input data" do
    assert Day13.part1(input()) == 6046
  end

  test "part 2 with example" do
    assert Day13.part2(example()) == 140
  end

  test "part 2 with my input data" do
    assert Day13.part2(input()) == 21423
  end

  defp example() do
    """
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
